require 'money/bank/google_currency'
Money.default_bank = Money::Bank::GoogleCurrency.new

class Place < ActiveRecord::Base
  
  serialize :photos

  validates_presence_of [:title, :place_type_id, :num_bedrooms, :max_guests, :city_id], :message => "101"

  validates_numericality_of [
    :num_bedrooms,
    :num_beds,
    :num_bathrooms,
    :sqm,
    :max_guests,
    :price_per_night,
    :price_per_week,
    :price_per_month,
    :price_final_cleanup,
    :price_security_deposit,
    :price_per_night_usd,
    :price_per_week_usd,
    :price_per_month_usd,
    :minimum_stay_days,
    :maximum_stay_days
  ], :allow_nil => true, :message => "118"

  attr_accessor :amenities, :location, :terms_of_offer

  belongs_to :user
  belongs_to :place_type
  belongs_to :city
  belongs_to :state
  belongs_to :country
  has_many   :availabilities
    
  before_update :save_amenities, :convert_prices_in_usd_cents, :convert_json_photos_to_array, :update_location_fields
  after_commit :delete_cache
    
  private
  
  def delete_cache
    delete_caches([])
  end
  
  def convert_json_photos_to_array
    self.photos = ActiveSupport::JSON.decode(self.photos) if photos_changed?
  end
  
  def save_amenities
    amenities.each_pair{ |field,v| self["amenities_#{field}"] = v } if self.amenities
  end
  
  # Convert all price fields into USD cents
  def convert_prices_in_usd_cents
    self.price_per_night_usd        = money_to_usd_cents(self.price_per_night,currency)         if price_per_night_changed? or currency_changed?
    self.price_per_week_usd         = money_to_usd_cents(self.price_per_week,currency)          if price_per_week_changed? or currency_changed?
    self.price_per_month_usd        = money_to_usd_cents(self.price_per_month,currency)         if price_per_month_changed? or currency_changed?
    self.price_final_cleanup_usd    = money_to_usd_cents(self.price_final_cleanup,currency)     if price_final_cleanup_changed? or currency_changed?
    self.price_security_deposit_usd = money_to_usd_cents(self.price_security_deposit,currency)  if price_security_deposit_changed? or currency_changed?
  end
  
  # Convert currency/money into USD cents
  def money_to_usd_cents(money, currency)
    money.to_money(currency).exchange_to(:USD).cents
  end
  
  def update_location_fields
    if self.city_id_changed?
      self.state_id = self.city.state.id
      self.country_id = self.city.country.id
    end
  end

end