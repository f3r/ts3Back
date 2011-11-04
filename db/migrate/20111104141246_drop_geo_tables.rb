class DropGeoTables < ActiveRecord::Migration
  def up
    drop_table :countries
    drop_table :states
    drop_table :cities
  end

  def down
    create_table "cities", :primary_key => "id", :force => true do |t|
      t.integer "geo_id"
      t.string  "geo_name",            :limit => 200,  :default => "",  :null => false
      t.string  "geo_ansiname",        :limit => 200,  :default => "",  :null => false
      t.string  "geo_alternate_names", :limit => 2000, :default => "",  :null => false
      t.float   "geo_latitude",                        :default => 0.0, :null => false
      t.float   "geo_longitude",                       :default => 0.0, :null => false
      t.string  "geo_feature_class",   :limit => 1
      t.string  "geo_feature_code",    :limit => 10
      t.string  "geo_country_code",    :limit => 2
      t.string  "geo_country_code2",   :limit => 60
      t.string  "geo_admin1_code",     :limit => 20,   :default => ""
      t.string  "geo_admin2_code",     :limit => 80,   :default => ""
      t.string  "geo_admin3_code",     :limit => 20,   :default => ""
      t.string  "geo_admin4_code",     :limit => 20,   :default => ""
      t.integer "geo_population",      :limit => 8,    :default => 0
      t.integer "geo_elevation",                       :default => 0
      t.integer "geo_gtopo30",                         :default => 0
      t.string  "geo_timezone",        :limit => 40
      t.date    "geo_mod_date"
    end
    add_index :cities, :geo_id
    add_index :cities, :geo_country_code
    add_index :cities, :geo_feature_class
    add_index :cities, :geo_feature_code

    create_table "countries", :primary_key => "id", :force => true do |t|
      t.string  "code_iso",             :limit => 2
      t.string  "code_iso3",            :limit => 3
      t.integer "code_iso_numeric",                    :default => 0
      t.string  "fips",                 :limit => 2
      t.string  "name",                 :limit => 200, :default => "", :null => false
      t.string  "capital",              :limit => 200, :default => "", :null => false
      t.integer "area",                 :limit => 8,   :default => 0
      t.integer "population",           :limit => 8,   :default => 0
      t.string  "continent",            :limit => 2
      t.string  "tld",                  :limit => 3
      t.string  "currency_code",        :limit => 3
      t.string  "currency_name",        :limit => 200
      t.string  "phone",                :limit => 80
      t.string  "postal_code_format",   :limit => 80
      t.string  "postal_code_regex",    :limit => 200
      t.string  "languages",            :limit => 200
      t.integer "geonameid"
      t.string  "neighbours",           :limit => 200
      t.string  "equivalent_fips_code", :limit => 2
    end
    add_index :countries, :code_iso
    add_index :countries, :code_iso3
    add_index :countries, :continent
    add_index :countries, :geonameid

    create_table "states", :primary_key => "id", :force => true do |t|
      t.integer "geo_id"
      t.string  "geo_name",            :limit => 200,  :default => "",  :null => false
      t.string  "geo_ansiname",        :limit => 200,  :default => "",  :null => false
      t.string  "geo_alternate_names", :limit => 2000, :default => "",  :null => false
      t.float   "geo_latitude",                        :default => 0.0, :null => false
      t.float   "geo_longitude",                       :default => 0.0, :null => false
      t.string  "geo_feature_class",   :limit => 1
      t.string  "geo_feature_code",    :limit => 10
      t.string  "geo_country_code",    :limit => 2
      t.string  "geo_country_code2",   :limit => 60
      t.string  "geo_admin1_code",     :limit => 20,   :default => ""
      t.string  "geo_admin2_code",     :limit => 80,   :default => ""
      t.string  "geo_admin3_code",     :limit => 20,   :default => ""
      t.string  "geo_admin4_code",     :limit => 20,   :default => ""
      t.integer "geo_population",      :limit => 8,    :default => 0
      t.integer "geo_elevation",                       :default => 0
      t.integer "geo_gtopo30",                         :default => 0
      t.string  "geo_timezone",        :limit => 40
      t.date    "geo_mod_date"
    end
    add_index :states, :geo_id
    add_index :states, :geo_country_code
    add_index :states, :geo_feature_class
    add_index :states, :geo_feature_code
  end
end
