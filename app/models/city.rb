class City < ActiveRecord::Base
  default_scope :order => 'geo_name ASC'

  belongs_to :country, :primary_key => 'code_iso', :foreign_key => 'geo_country_code'
  has_many :places

  alias_attribute :name, :geo_name

  def state
    State.select("
      id, 
      geo_name as name, 
      geo_latitude as lat, 
      geo_longitude as lon, 
      geo_country_code, 
      geo_admin1_code
    ").where(
      :geo_country_code => self.geo_country_code, 
      :geo_admin1_code => self.geo_admin1_code).first
  end

end