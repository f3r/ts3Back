class State < ActiveRecord::Base
  default_scope :order => 'geo_name ASC'

  belongs_to :country, :primary_key => 'code_iso', :foreign_key => 'geo_country_code'
  has_many :places
  has_many :cities, 
    :class_name => "City", 
    :finder_sql => proc {  
      "SELECT cities.* " +
      "FROM cities, states " +
      "WHERE states.geo_country_code = cities.geo_country_code " +
      "AND states.geo_admin1_code = cities.geo_admin1_code " +
      "AND states.id = #{id}"
    }
  
end