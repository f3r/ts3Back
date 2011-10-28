class Place < ActiveRecord::Migration
  def change
    create_table :places do |t|

      t.integer :user_id
      t.boolean :published, :default => false

      # Place Description
      t.string :title
      t.text :description 
      t.integer :place_type_id        # Relates to place_type model
      t.integer :num_bedrooms 
      t.integer :num_beds
      t.integer :num_bathrooms 
      t.float :sqm                   # Should be able to calculate sqf
      t.integer :max_guests
      t.text :photos                  # array of photos with description

      # Geographical stuff
      # Province/Country updates automatically on insert/update
      t.integer :city_id              # Relates to cities model
      t.integer :province_id          # Relates to provinces model
      t.integer :country_id           # Relates to countries model
      t.string :address_1 
      t.string :address_2, :null => true
      t.string :zip
      t.float :lat, :limit => 53, :null => true # updates on address change
      t.float :lon, :limit => 53, :null => true # updates on address change
      t.text :directions, :null => true

      # Amenities included (A-Z)
      t.boolean :amenities_aircon, :default => false
      t.boolean :amenities_breakfast, :default => false
      t.boolean :amenities_buzzer_intercom, :default => false
      t.boolean :amenities_cable_tv, :default => false
      t.boolean :amenities_dryer, :default => false
      t.boolean :amenities_doorman, :default => false
      t.boolean :amenities_elevator, :default => false
      t.boolean :amenities_family_friendly, :default => false
      t.boolean :amenities_gym, :default => false
      t.boolean :amenities_hot_tub, :default => false
      t.boolean :amenities_kitchen, :default => false
      t.boolean :amenities_handicap, :default => false
      t.boolean :amenities_heating, :default => false
      t.boolean :amenities_hot_water, :default => false
      t.boolean :amenities_internet, :default => false
      t.boolean :amenities_internet_wifi, :default => false
      t.boolean :amenities_jacuzzi, :default => false
      t.boolean :amenities_parking_included, :default => false
      t.boolean :amenities_pets_allowed, :default => false
      t.boolean :amenities_pool, :default => false
      t.boolean :amenities_smoking_allowed, :default => false
      t.boolean :amenities_suitable_events, :default => false
      t.boolean :amenities_tennis, :default => false
      t.boolean :amenities_tv, :default => false
      t.boolean :amenities_washer, :default => false

      # Pricing of the offer
      # Currency from: https://github.com/RubyMoney/money/blob/master/config/currency.json
      t.string :currency                # Currency_iso
      t.integer :price_per_night        # Currency Units, not cents 1=$1
      t.integer :price_per_week, :null => true
      t.integer :price_per_month, :null => true
      t.integer :price_final_cleanup, :default => 0
      t.integer :price_security_deposit, :default => 0
      # Fields for price comparison, must be updated with currency exchange every couple of days
      t.integer :price_per_night_usd    # Dollar Cents
      t.integer :price_per_week_usd
      t.integer :price_per_month_usd

      # Terms of the offer
      t.string :check_in_after, :null => true   #11:00 / 11:30 / 13:30
      t.string :check_out_before, :null => true #11:00 / 11:30 / 13:30
      t.integer :minimum_stay_days, :default => 0      # 0 means no minimum
      t.integer :maximum_stay_days, :default => 0      # 0 means no maximum
      t.text :house_rules, :null => true
      t.integer :cancellation_policy, :default => 1    # should align with frontend

      #  cancellation_policies
      #       1: flexible               # full refund 1 day prior to arrival, except fees
      #       2: moderate               # full refund 5 days prior to arrival, except fees
      #       3: strict                 # 50% refund up until 1 week prior, except fees

      # Averaged reviews for the place
      t.float :reviews_overall, :default => 0    # average of averages
      t.float :reviews_accuracy_avg, :default => 0
      t.float :reviews_cleanliness_avg, :default => 0
      t.float :reviews_checkin_avg, :default => 0
      t.float :reviews_communication_avg, :default => 0
      t.float :reviews_location_avg, :default => 0
      t.float :reviews_value_avg, :default => 0

      t.timestamps
    end
    add_index :places, :user_id
    add_index :places, :place_type_id
    add_index :places, :city_id
    add_index :places, :province_id
    add_index :places, :country_id
    add_index :places, :amenities_aircon
    add_index :places, :amenities_breakfast
    add_index :places, :amenities_buzzer_intercom
    add_index :places, :amenities_cable_tv
    add_index :places, :amenities_dryer
    add_index :places, :amenities_doorman
    add_index :places, :amenities_elevator
    add_index :places, :amenities_family_friendly
    add_index :places, :amenities_gym
    add_index :places, :amenities_hot_tub
    add_index :places, :amenities_kitchen
    add_index :places, :amenities_handicap
    add_index :places, :amenities_heating
    add_index :places, :amenities_hot_water
    add_index :places, :amenities_internet
    add_index :places, :amenities_internet_wifi
    add_index :places, :amenities_jacuzzi
    add_index :places, :amenities_parking_included
    add_index :places, :amenities_pets_allowed
    add_index :places, :amenities_pool
    add_index :places, :amenities_smoking_allowed
    add_index :places, :amenities_suitable_events
    add_index :places, :amenities_tennis
    add_index :places, :amenities_tv
    add_index :places, :amenities_washer
      
  end
end