class Country < ActiveRecord::Base
  default_scope :order => 'name ASC'
  
  has_many :places, :primary_key => 'code_iso', :foreign_key => 'geo_country_code'
  has_many :states, :primary_key => 'code_iso', :foreign_key => 'geo_country_code'
  has_many :cities, :primary_key => 'code_iso', :foreign_key => 'geo_country_code'

end