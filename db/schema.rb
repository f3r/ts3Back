# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111109182944) do

  create_table "addresses", :force => true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "country"
    t.string   "zip"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider"], :name => "index_authentications_on_provider"
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "availabilities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_id"
    t.date     "date_start"
    t.date     "date_end"
    t.integer  "price_per_night"
    t.string   "comment"
    t.integer  "availability_type"
  end

  add_index "availabilities", ["place_id"], :name => "index_availabilities_on_place_id"

  create_table "cities", :force => true do |t|
    t.string "name"
    t.float  "lat"
    t.float  "lon"
    t.string "state"
    t.string "country"
    t.string "country_code"
    t.string "cached_complete_name"
  end

  add_index "cities", ["country"], :name => "index_cities_on_country"
  add_index "cities", ["country_code"], :name => "index_cities_on_country_code"
  add_index "cities", ["state"], :name => "index_cities_on_state"

  create_table "comments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "place_id"
    t.text     "comment"
    t.boolean  "owner"
  end

  add_index "comments", ["place_id"], :name => "index_comments_on_place_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "place_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "published",                               :default => false
    t.string   "title"
    t.text     "description"
    t.integer  "place_type_id"
    t.integer  "num_bedrooms"
    t.integer  "num_beds"
    t.integer  "num_bathrooms"
    t.float    "size"
    t.integer  "max_guests"
    t.text     "photos"
    t.integer  "city_id"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "zip"
    t.float    "lat"
    t.float    "lon"
    t.text     "directions"
    t.boolean  "amenities_aircon",                        :default => false
    t.boolean  "amenities_breakfast",                     :default => false
    t.boolean  "amenities_buzzer_intercom",               :default => false
    t.boolean  "amenities_cable_tv",                      :default => false
    t.boolean  "amenities_dryer",                         :default => false
    t.boolean  "amenities_doorman",                       :default => false
    t.boolean  "amenities_elevator",                      :default => false
    t.boolean  "amenities_family_friendly",               :default => false
    t.boolean  "amenities_gym",                           :default => false
    t.boolean  "amenities_hot_tub",                       :default => false
    t.boolean  "amenities_kitchen",                       :default => false
    t.boolean  "amenities_handicap",                      :default => false
    t.boolean  "amenities_heating",                       :default => false
    t.boolean  "amenities_hot_water",                     :default => false
    t.boolean  "amenities_internet",                      :default => false
    t.boolean  "amenities_internet_wifi",                 :default => false
    t.boolean  "amenities_jacuzzi",                       :default => false
    t.boolean  "amenities_parking_included",              :default => false
    t.boolean  "amenities_pets_allowed",                  :default => false
    t.boolean  "amenities_pool",                          :default => false
    t.boolean  "amenities_smoking_allowed",               :default => false
    t.boolean  "amenities_suitable_events",               :default => false
    t.boolean  "amenities_tennis",                        :default => false
    t.boolean  "amenities_tv",                            :default => false
    t.boolean  "amenities_washer",                        :default => false
    t.string   "currency"
    t.integer  "price_per_night"
    t.integer  "price_per_week"
    t.integer  "price_per_month"
    t.integer  "price_final_cleanup",                     :default => 0
    t.integer  "price_security_deposit",                  :default => 0
    t.integer  "price_per_night_usd"
    t.integer  "price_per_week_usd"
    t.integer  "price_per_month_usd"
    t.string   "check_in_after"
    t.string   "check_out_before"
    t.integer  "minimum_stay_days",                       :default => 0
    t.integer  "maximum_stay_days",                       :default => 0
    t.text     "house_rules"
    t.integer  "cancellation_policy",                     :default => 1
    t.float    "reviews_overall",                         :default => 0.0
    t.float    "reviews_accuracy_avg",                    :default => 0.0
    t.float    "reviews_cleanliness_avg",                 :default => 0.0
    t.float    "reviews_checkin_avg",                     :default => 0.0
    t.float    "reviews_communication_avg",               :default => 0.0
    t.float    "reviews_location_avg",                    :default => 0.0
    t.float    "reviews_value_avg",                       :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price_final_cleanup_usd"
    t.integer  "price_security_deposit_usd"
    t.float    "size_sqm"
    t.float    "size_sqf"
    t.string   "size_unit"
    t.string   "city_name"
    t.string   "country_name"
    t.string   "state_name"
    t.string   "country_code",               :limit => 2
    t.float    "price_sqf_usd"
  end

  add_index "places", ["amenities_aircon"], :name => "index_places_on_amenities_aircon"
  add_index "places", ["amenities_breakfast"], :name => "index_places_on_amenities_breakfast"
  add_index "places", ["amenities_buzzer_intercom"], :name => "index_places_on_amenities_buzzer_intercom"
  add_index "places", ["amenities_cable_tv"], :name => "index_places_on_amenities_cable_tv"
  add_index "places", ["amenities_doorman"], :name => "index_places_on_amenities_doorman"
  add_index "places", ["amenities_dryer"], :name => "index_places_on_amenities_dryer"
  add_index "places", ["amenities_elevator"], :name => "index_places_on_amenities_elevator"
  add_index "places", ["amenities_family_friendly"], :name => "index_places_on_amenities_family_friendly"
  add_index "places", ["amenities_gym"], :name => "index_places_on_amenities_gym"
  add_index "places", ["amenities_handicap"], :name => "index_places_on_amenities_handicap"
  add_index "places", ["amenities_heating"], :name => "index_places_on_amenities_heating"
  add_index "places", ["amenities_hot_tub"], :name => "index_places_on_amenities_hot_tub"
  add_index "places", ["amenities_hot_water"], :name => "index_places_on_amenities_hot_water"
  add_index "places", ["amenities_internet"], :name => "index_places_on_amenities_internet"
  add_index "places", ["amenities_internet_wifi"], :name => "index_places_on_amenities_internet_wifi"
  add_index "places", ["amenities_jacuzzi"], :name => "index_places_on_amenities_jacuzzi"
  add_index "places", ["amenities_kitchen"], :name => "index_places_on_amenities_kitchen"
  add_index "places", ["amenities_parking_included"], :name => "index_places_on_amenities_parking_included"
  add_index "places", ["amenities_pets_allowed"], :name => "index_places_on_amenities_pets_allowed"
  add_index "places", ["amenities_pool"], :name => "index_places_on_amenities_pool"
  add_index "places", ["amenities_smoking_allowed"], :name => "index_places_on_amenities_smoking_allowed"
  add_index "places", ["amenities_suitable_events"], :name => "index_places_on_amenities_suitable_events"
  add_index "places", ["amenities_tennis"], :name => "index_places_on_amenities_tennis"
  add_index "places", ["amenities_tv"], :name => "index_places_on_amenities_tv"
  add_index "places", ["amenities_washer"], :name => "index_places_on_amenities_washer"
  add_index "places", ["city_id"], :name => "index_places_on_city_id"
  add_index "places", ["city_name"], :name => "index_places_on_city_name"
  add_index "places", ["country_code"], :name => "index_places_on_country_code"
  add_index "places", ["country_name"], :name => "index_places_on_country_name"
  add_index "places", ["place_type_id"], :name => "index_places_on_place_type_id"
  add_index "places", ["state_name"], :name => "index_places_on_state_name"
  add_index "places", ["user_id"], :name => "index_places_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.date     "birthdate"
    t.string   "timezone"
    t.string   "phone_mobile"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "pref_language"
    t.string   "pref_currency"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
