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

  after_commit :delete_cache
    
  private
  
  def delete_cache
    delete_caches([])
  end

end