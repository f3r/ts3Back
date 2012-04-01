require 'securerandom'
class Alert < ActiveRecord::Base
  using_access_control
  belongs_to :user
  serialize :query
  serialize :results
  validates_presence_of [:query, :user_id, :schedule, :alert_type], :message => "101"
  validates_inclusion_of :delivery_method, :in => ["email", "sms", "email_sms"], :message => "103"
  validates_inclusion_of :schedule, :in => ["daily", "weekly", "monthly"], :message => "103"
  
  attr_protected :search_code
  
  before_create :set_search_code, :set_delivered_at, :set_results
  before_save :clear_empty_query_values

  default_scope where(:deleted_at => nil)

  def soft_delete
    ActiveRecord::Base.record_timestamps = false
    self.deleted_at = Time.now
    self.save
    ActiveRecord::Base.record_timestamps = true
  end

  # TODO: finish alerts, improve queries, validations
  def self.send_alerts
    alerts = []
    alerts+=Alert.where(:active => true, :schedule => "daily").where(['delivered_at < ?', Time.now - 1.day])
    alerts+=Alert.where(:active => true, :schedule => "weekly").where(['delivered_at < ?', Time.now - 1.week])
    alerts+=Alert.where(:active => true, :schedule => "monthly").where(['delivered_at < ?', Time.now - 1.month])
    
    for alert in alerts
      AlertMailer.send_alert(
        alert.user, 
        alert.get_places(:search_type => "new_results"),
        alert.get_places(:search_type => "recently_added")
      ).deliver
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
    puts search_params

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
  
  private

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

end