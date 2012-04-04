require 'declarative_authorization/maintenance'
require 'securerandom'
class Alert < ActiveRecord::Base
  using_access_control
  belongs_to :user
  serialize :query
  serialize :results
  validates_presence_of [:query, :user_id, :schedule, :alert_type], :message => "101"
  validates_inclusion_of :delivery_method, :in => ["email", "sms", "email_sms"], :message => "103"
  validates_inclusion_of :schedule, :in => ["daily", "weekly", "monthly"], :message => "103"
  validate :validate_query_dates

  attr_protected :search_code

  before_create :set_search_code, :set_delivered_at, :set_results
  before_save :clear_empty_query_values

  default_scope where(:deleted_at => nil)

  # keeps alerts for a while, avoids breaking links sent through email
  def soft_delete
    ActiveRecord::Base.record_timestamps = false
    self.deleted_at = Time.now
    self.save
    ActiveRecord::Base.record_timestamps = true
  end

  def self.send_alerts
    alerts = Alert.find_by_sql(["
      SELECT * from alerts 
      WHERE ((schedule = ? AND delivered_at < ?) OR (schedule = ? AND delivered_at < ?) OR (schedule = ? AND delivered_at < ?)) AND active = ?",
      "daily", Time.now - 1.day,
      "weekly", Time.now - 1.week,
      "monthly", Time.now - 1.month,
      true
    ])
    if !alerts.blank?
      for alert in alerts
        if alert.valid_alert?
          new_results = alert.get_places(:search_type => "new_results")
          recently_added = alert.get_places(:search_type => "recently_added")
          if new_results or recently_added # send email only if results are found
            city = City.find(alert['query']['city_id'].to_i)
            mailer = AlertMailer.send_alert(alert.user, alert, city, new_results, recently_added)
            if mailer.deliver # deliver alerts
              alert.update_delivered(new_results) if new_results # update results
            end
          end
        end
      end      
    end
  end
  
  # search_type:
  # recently_added gets places added since last delivery
  # new_results gets new results since the previous query
  def get_places(opts = {})
    @search_fields = [
      :id, :title, :city_id, :size_sqf, :size_sqm, :reviews_overall, :photos, 
      :currency, :num_bedrooms, :num_bathrooms, :favorited, 
      :price_per_month_usd, :price_per_month
    ]
    @user_fields = [:id, :first_name, :last_name, :avatar_file_name, :role]
    @place_type_fields = [:id,:name]

    if opts[:search_type] == "recently_added"
      search_params = self.query.merge({"date_from" => self.delivered_at})
    elsif opts[:search_type] == "new_results"
      search_params = self.query.merge({"exclude_ids" => self.results})
    else
      search_params = self.query
    end

    place_search = PlaceSearch.new(self.user, search_params)
      if !place_search.all_results.blank?
        filtered_places = filter_fields(place_search.all_results, @search_fields, { :additional_fields => {
          :user       => @user_fields,
          :place_type => @place_type_fields },
        :currency => self.query['currency']
        })
        return filtered_places
      else
        return nil
      end
  end
  
  # purges deleted alerts after x ammount of time
  def self.purge_deleted(range = 1.month)
    Authorization::Maintenance::without_access_control do
      Alert.unscoped.destroy_all(["deleted_at < ?", Time.now - range])
    end
  end
  
  # checks if alert is still valid, deactivates expired searches
  def valid_alert?    
    check_in = self.query["check_in"].to_datetime if self.query["check_in"]
    check_out = self.query["check_out"].to_datetime if self.query["check_out"]
    if (check_in && (check_in < Time.now)) or (check_out && (check_out < Time.now))
      Authorization::Maintenance::without_access_control do
        ActiveRecord::Base.record_timestamps = false
        self.update_attributes({:active => false})
        ActiveRecord::Base.record_timestamps = true
      end
      return false
    else
      return true
    end
  end

  # update delivered_at and results array (ignore this results on the next alert)
  def update_delivered(new_results)
    Authorization::Maintenance::without_access_control do
      new_results_ids = new_results.map{|x| x[:id]}
      results_ids = (self.results + new_results_ids).uniq
      ActiveRecord::Base.record_timestamps = false
      self.update_attributes({:delivered_at => Date.today, :results => results_ids})
      ActiveRecord::Base.record_timestamps = true
    end
  end

  private
  
  # used for short url
  def generate_search_code
    search_code = Time.now.strftime("%y%m%d#{SecureRandom.urlsafe_base64(4).upcase}")
    search = Alert.find_by_search_code(search_code)
    if search
      self.generate_search_code
    else
      search_code
    end
  end

  def set_search_code
    self.search_code = generate_search_code
  end
  
  # set initial delivery day as today.
  def set_delivered_at
    self.delivered_at = Date.today
  end
  
  def clear_empty_query_values
    self.query = self.query.delete_if { |k, v| v.empty? }
  end
  
  def set_results
    search = PlaceSearch.new(self.user, self.query)
    if search.valid?
      self.results = search.all_results_ids
    end
  end

  def validate_query_dates
    if query_changed? or (active_changed? && active_was == false)
      # check if check in and check out are valid
      check_in = query["check_in"].to_datetime if query["check_in"]
      check_out = query["check_out"].to_datetime if query["check_out"]
      if (check_in && (check_in < Time.now)) or (check_out && (check_out < Time.now))
        errors.add(:query, "119")
      end
    end
  end

end