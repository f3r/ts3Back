include GeneralHelper
require 'money/bank/google_currency'
Money.default_bank = Money::Bank::GoogleCurrency.new

class Place < ActiveRecord::Base
  using_access_control

  geocoded_by :full_address, :latitude  => :lat, :longitude => :lon

  validates_presence_of   [:title, :place_type_id, :num_bedrooms, :max_guests, :city_id, :user_id], :message => "101"
  validates_inclusion_of  :size_unit, :in => ["meters", "feet"], :allow_nil => true, :if => :size?, :message => "129"
  validates_inclusion_of  :stay_unit,
                          :in => STAY_UNITS,
                          :message => "129",
                          :allow_nil => true,
                          :if => Proc.new { |place| (place.minimum_stay && place.minimum_stay > 0) or (place.maximum_stay && place.maximum_stay > 0) }

  validates_numericality_of [
    :num_bedrooms,
    :num_beds,
    :num_bathrooms,
    :size,
    :max_guests,
    :price_per_night,
    :price_per_week,
    :price_per_month,
    :price_final_cleanup,
    :price_security_deposit,
    :price_per_night_usd,
    :price_per_week_usd,
    :price_per_month_usd,
    :minimum_stay,
    :maximum_stay
  ], :allow_nil => true, :message => "118"

  validates_numericality_of :maximum_stay, :greater_than_or_equal_to => :minimum_stay, :message => "140", :if => Proc.new { |place| !place.minimum_stay.blank? && place.minimum_stay > 0 && place.maximum_stay != 0 }

  validates_numericality_of :city_id, :message => "118"

  attr_accessor :amenities, :location, :terms_of_offer
  attr_accessible :currency
  attr_protected :published

  belongs_to  :user
  belongs_to  :place_type
  belongs_to  :city
  has_many    :availabilities, :dependent => :destroy
  has_many    :comments, :dependent => :destroy
  has_many    :transactions, :dependent => :destroy
  has_many    :photos, :dependent => :destroy, :order => :position
  has_many    :favorites, :as => :favorable, :dependent => :destroy

  before_save   :save_amenities,
                :convert_prices_in_usd_cents,
                :update_size_fields,
                :update_price_sqf_field,
                :geocode
  validate      :validate_publishing,
                :update_location_fields,
                :check_zip,
                :validate_currency,
                :validate_stays
  after_commit  :delete_cache

  before_validation :check_hong_kong_zipcode

  self.per_page = 20

  scope :published,    where("published")
  scope :unpublished,  where("not published")

  def primary_photo
    self.photos.first
  end

  def publish!
    self.published = true
    self.save
  end

  def unpublish!
    self.published = false
    self.save
  end

  def publish_check!
    self.published = true
    self.valid?
  end

  def full_address
    [address_1, address_2, city_name, state_name, country_code].join(' ').gsub("  "," ")
  end

  def amenities_list
    amenities_list = []
    self.attributes.each{ |field, v|
      amenities_list << field if (field.starts_with? 'amenities_') && v==true
    }
    return amenities_list
  end

  def place_availability(check_in, check_out, new_currency=nil, user=nil)

    errors = validate_attributes(Transaction, {:check_in => check_in, :check_out => check_out, :place => self})

    if errors.blank?
      check_in = check_in.to_date
      check_out = check_out.to_date

      requested_dates = (check_in..check_out).to_a
      total_days = requested_dates.count

      # set default prices in the original currency
      price_per_night = self.price_per_night.to_f rescue nil
      price_per_night = self.price_per_week.to_f / 7 if self.price_per_week && total_days >= 7 && total_days < 28
      price_per_night = self.price_per_month.to_f / 31 if self.price_per_month && total_days > 28

      price_final_cleanup = self.price_final_cleanup
      price_security_deposit = self.price_security_deposit
      currency = self.currency

      availabilities_all = self.availabilities.all.map{|x| x}
      unavailabilities = availabilities_all.map{|x| x if x.availability_type == 1 }.compact
      availabilities = availabilities_all.map{|x| x if x.availability_type == 2 or x.availability_type == 3}.compact

      # check for ocuppied dates
      unavailable_dates = []
      if !unavailabilities.blank?
        for unavailability in unavailabilities
          unavailability_dates = (unavailability.date_start..unavailability.date_end).to_a
          intersections = requested_dates & unavailability_dates
          if !intersections.blank?
            for date in intersections
              unavailable_dates << {:date => date, :comment => unavailability.comment}
            end
          end
        end
      end

      # add active transaction dates to unavailable_dates array
      if user
        user_transactions = user.transactions.active.where(:place_id => self.id)
        for transaction in user_transactions
          unavailability_dates = (transaction.check_in..transaction.check_out).to_a
          intersections = requested_dates & unavailability_dates
          if !intersections.blank?
            for date in intersections
              unavailable_dates << {:date => date, :comment => "Already requested"}
            end
          end
        end
      end

      if unavailable_dates.blank?

        dates = []
        for date in requested_dates
          # exchange currency if new_currency param is present
          if new_currency && valid_currency?(new_currency)
            requested_currency_price_per_night = exchange_currency(price_per_night, self.currency, new_currency)
          end
          foo = { :date => date, :price_per_night => price_per_night }
          foo.merge!({:requested_currency_price_per_night => requested_currency_price_per_night}) if requested_currency_price_per_night
          dates << foo
        end

        if availabilities
          # replaces regular price with the availability price on the affected dates
          for availability in availabilities

            # exchange currency if new_currency param is present
            if new_currency && valid_currency?(new_currency)
              requested_currency_price_per_night = exchange_currency(availability.price_per_night, self.currency, new_currency)
            end

            availability_dates = (availability.date_start..availability.date_end).to_a
            intersections = requested_dates & availability_dates
            if !intersections.blank?
              for date in intersections
                dates.delete_if {|hash| hash[:date] == date}
                foo = {:date => date, :price_per_night => availability.price_per_night, :comment => availability.comment}
                foo.merge!({:requested_currency_price_per_night => requested_currency_price_per_night}) if requested_currency_price_per_night
                dates << foo
              end
            end
          end
        end

        dates = dates.sort_by { |hash| hash[:date] }

        # get the sum of price_per_night
        sub_total = 0
        dates.map{|hash| sub_total += hash[:price_per_night]}

        if new_currency && valid_currency?(new_currency)
          requested_currency = {
            :requested_currency_price_final_cleanup => exchange_currency(price_final_cleanup, self.currency, new_currency),
            :requested_currency_price_security_deposit => exchange_currency(price_security_deposit, self.currency, new_currency),
            :requested_currency => new_currency,
            :requested_currency_sub_total => exchange_currency(sub_total, self.currency, new_currency),
          }
        end

        results = {
          :total_days => total_days,
          :price_final_cleanup => price_final_cleanup,
          :price_security_deposit => price_security_deposit,
          :currency => currency,
          :sub_total => sub_total
        }
        results.merge!(requested_currency) if requested_currency
        results.merge!(:price_per_night => price_per_night) if price_per_night && total_days < 7
        results.merge!(:price_per_week => price_per_week) if price_per_week && total_days >= 7 && total_days < 28
        results.merge!(:price_per_month => price_per_month) if price_per_month && total_days >= 28
        return results

      elsif unavailable_dates
        return { :err => {:place => [136]}, :dates => unavailable_dates }
      end

    else
      return { :err => format_errors(errors) }
    end

  end

  # auto decline transactions on a date range
  def auto_decline_transactions(check_in, check_out)
    transactions = self.transactions.where("state != ?", "confirmed_rental").where("check_in <= ?", check_out).where("check_out >= ?", check_in).active
    transactions.each{|x| x.auto_decline! }
  end

  # Include the photos on serialization
  # def as_json(opts = {})
  #   super(opts.merge(:include => [:photos]))
  # end
  def convert_prices_in_usd_cents!
    convert_prices_in_usd_cents(true)
    self.save(:validate => false)
  end

  private

  def delete_cache
    delete_caches([])
  end

  def save_amenities
    amenities.each_pair{ |field,v| self["amenities_#{field}"] = v } if self.amenities
  end

  # Convert all price fields into USD cents
  def convert_prices_in_usd_cents(force = false)
    if !currency.nil?
      # self.price_per_night_usd        = money_to_usd_cents(self.price_per_night,currency)         if price_per_night_changed? or currency_changed?
      # self.price_per_week_usd         = money_to_usd_cents(self.price_per_week,currency)          if price_per_week_changed? or currency_changed?
      self.price_per_month_usd        = money_to_usd_cents(self.price_per_month,currency)         if force || price_per_month_changed? || currency_changed?
      self.price_final_cleanup_usd    = money_to_usd_cents(self.price_final_cleanup,currency)     if force || price_final_cleanup_changed? || currency_changed?
      self.price_security_deposit_usd = money_to_usd_cents(self.price_security_deposit,currency)  if force || price_security_deposit_changed? || currency_changed?
    end
  end

  # Convert currency/money into USD cents
  def money_to_usd_cents(money, currency)
    money.to_money(currency).exchange_to(:USD).cents if money && currency
  end

  def update_location_fields
    if self.city_id_changed? && self.city
      self.city_name = self.city.name
      self.state_name = self.city.state
      self.country_name = self.city.country
      self.country_code = self.city.country_code
    elsif self.city.blank?
      errors.add(:city_id, "132")
    end
  end

  def update_size_fields
    if (self.size_changed? or self.size_unit_changed?) && !self.size.blank? && !self.size_unit.blank?
      case size_unit
      when "meters"
        self.size_sqm = size
        self.size_sqf = size * 10.7639104
      when "feet"
        self.size_sqf = size
        self.size_sqm = size * 0.09290304
      end
    elsif (self.size_changed? or self.size_unit_changed?) && (self.size.blank? or self.size_unit.blank?)
      self.size = nil
      self.size_sqm = nil
      self.size_sqf = nil
      self.size_unit = nil
    end
  end

  def update_price_sqf_field
    if (self.size_sqf_changed? && !self.size_sqf.blank?) or price_per_month_changed? #or price_per_night_changed? or price_per_week_changed?
      # if !price_per_night_usd.blank?
      #   price = price_per_night_usd
      # elsif !price_per_week_usd.blank?
      #   price = price_per_week_usd / 7
      if !price_per_month_usd.blank?
        price = price_per_month_usd / 31
      end
      price_sqf_usd = price / size_sqf rescue nil
      self.price_sqf_usd = price_sqf_usd
    end
  end

  # Adds validation errors if published column is affected and the place doesn't meet the requirements
  def validate_publishing
    if self.changed? && self.published

      unpublish_place = false

      # Place must have 3 pictures
      if self.photos.blank? || self.photos.size < 3
        unpublish_place = true
        errors.add(:publish, "123") if published_changed?
      end

      # Place must have at least 1 amenity
      if self.amenities_list.blank? || self.amenities_list.count < 1
        unpublish_place = true
        errors.add(:publish, "143") if published_changed?
      end

      # general fields
      if self.size.blank?
        unpublish_place = true
        errors.add(:publish, "146") if published_changed?
      end

      if self.address_1.blank?
        unpublish_place = true
        errors.add(:publish, "144") if published_changed?
      end

      if self.zip.blank?
        unpublish_place = true
        errors.add(:publish, "145") if published_changed?
      end

      # Description must have at least 5 words
      # if self.description.blank? or self.description.blank? or self.description.split.size < 5
      #   unpublish_place = true
      #   errors.add(:publish, "124") if published_changed?
      # end

      # NOTE: We are moving to a only month pricing, so this is removed (f3r)
      # if !stay_unit.blank?
      #   case stay_unit
      #   when "days"
      #     min_stay = minimum_stay if minimum_stay
      #     max_stay = maximum_stay if maximum_stay
      #   when "weeks"
      #     min_stay = minimum_stay * 7 if minimum_stay
      #     max_stay = maximum_stay * 7 if maximum_stay
      #   when "months"
      #     min_stay = minimum_stay * 31 if minimum_stay
      #     max_stay = maximum_stay * 31 if maximum_stay
      #   end
      #
      #   if min_stay < 7 && price_per_night.blank?
      #     unpublish_place = true
      #     errors.add(:publish, "126") if published_changed?
      #   end
      #   if min_stay >= 7 && min_stay < 28 && price_per_week.blank?
      #     unpublish_place = true
      #     errors.add(:publish, "126") if published_changed?
      #   end
      #   if (min_stay > 28 or max_stay > 28) && price_per_month.blank?
      #     unpublish_place = true
      #     errors.add(:publish, "126") if published_changed?
      #   end
      # end
      #
      # empty_price = true
      # for stay_unit in STAY_UNITS
      #   case stay_unit
      #   when "days"
      #     unit = "night"
      #   when "weeks"
      #     unit = "week"
      #   when "months"
      #     unit = "month"
      #   end
      #   if self.send("price_per_" + unit).blank?
      #     unpublish_place = true
      #     errors.add(:publish, "126") if published_changed?
      #   end
      # end

      if self.price_per_month.blank?
        unpublish_place = true
        errors.add(:publish, "126") if published_changed?
      end

      if self.currency.blank?
        unpublish_place = true
        errors.add(:publish, "127") if published_changed?
      end

      # NOTE: Security deposit is now not required (f3r)
      # if self.price_security_deposit.blank?
      #   unpublish_place = true
      #   errors.add(:publish, "128") if published_changed?
      # end

      self.published = false if unpublish_place == true
    end
  end

  # Adds validation errors if the currency is not supported
  def validate_currency
    errors.add(:currency, "135") unless valid_currency?(currency)
  end

  # Check for valid zip code, HK doesn't have a standard format.
  def check_zip
    if zip_changed? or city_id_changed?
      case country_code
      when "AU"
        regex = /\d{4}/
      when "CN"
        regex = /\d{6}/
      when "IN"
        regex = /\d{6}/
      when "ID"
        regex = /\d{5}/
      when "MY"
        regex = /\d{5}/
      when "PH"
        regex = /\d{4}/
      when "SG"
        regex = /\d{6}/
      when "TH"
        regex = /\d{5}/
      when "VN"
        regex = /\d{6}/
      when "US"
        regex = /\d{5}([ \-]\d{4})?/
      end
      errors.add(:zip, "103") if regex && zip && !zip.match(regex)
    end
  end

  def validate_stays
    if ((!minimum_stay.blank? && minimum_stay > 0) or (!maximum_stay.blank? && maximum_stay > 0)) && (!stay_unit.blank? && STAY_UNITS.include?(stay_unit))

      case stay_unit
      when "days"
        min_stay = minimum_stay if minimum_stay
        max_stay = maximum_stay if maximum_stay
      when "weeks"
        min_stay = minimum_stay * 7 if minimum_stay
        max_stay = maximum_stay * 7 if maximum_stay
      when "months"
        min_stay = minimum_stay * 31 if minimum_stay
        max_stay = maximum_stay * 31 if maximum_stay
      end

      # if min_stay < 7
      #   errors.add(:price_per_night, "101") if price_per_night.blank?
      # end
      #
      # if min_stay >= 7 && min_stay < 28
      #   errors.add(:price_per_week, "101") if price_per_week.blank?
      # end

      if min_stay > 28 or max_stay > 28
        errors.add(:price_per_month, "101") if price_per_month.blank?
      end

    else
      self.minimum_stay = 0 unless !self.minimum_stay.blank?
      self.maximum_stay = 0 unless !self.maximum_stay.blank?
      self.stay_unit = "months" unless !self.stay_unit.blank?
    end

  end

  def check_hong_kong_zipcode
    if self.city_id == 2
      self.zip ||= '999077'
    end
  end
end