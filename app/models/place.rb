require 'money/bank/google_currency'
Money.default_bank = Money::Bank::GoogleCurrency.new

class Place < ActiveRecord::Base

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

  before_update :save_amenities, :convert_prices_in_usd_cents
  after_commit :delete_cache
    
  private
  
  def delete_cache
    delete_caches([])
  end
  
  def save_amenities
    amenities.each_pair{ |field,v| self["amenities_#{field}"] = v } if self.amenities
  end
  
  # Convert all price fields into USD cents
  def convert_prices_in_usd_cents
    self.price_per_night_usd = money_to_usd_cents(self.price_per_night,currency) if self.price_per_night
    self.price_per_week_usd = money_to_usd_cents(self.price_per_week,currency) if self.price_per_week
    self.price_per_month_usd = money_to_usd_cents(self.price_per_month,currency) if self.price_per_month
    self.price_final_cleanup_usd = money_to_usd_cents(self.price_final_cleanup,currency) if self.price_final_cleanup
    self.price_security_deposit_usd = money_to_usd_cents(self.price_security_deposit,currency) if self.price_security_deposit
  end
  
  # Convert currency/money into USD cents
  def money_to_usd_cents(money, currency)
    money.to_money(currency).exchange_to(:USD).cents
  end

end