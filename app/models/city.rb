class City < ActiveRecord::Base
  default_scope :order => 'geo_name ASC'

  belongs_to :country, :primary_key => 'code_iso', :foreign_key => 'geo_country_code'

  def state
    State.where(:geo_country_code => self.geo_country_code, :geo_admin1_code => self.geo_admin1_code).first
  end

end