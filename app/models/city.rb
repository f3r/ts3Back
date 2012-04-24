class City < ActiveRecord::Base
  default_scope :order => 'position ASC'
  has_many :places

  before_save :update_cached_complete_name
  after_commit  :delete_cache

  scope :active,    where("active")
  scope :inactive,  where("not active")

  def activate!
    self.active = true
    self.save
  end

  def deactivate!
    self.active = false
    self.save
  end

  def complete_name
    "#{self.name}, #{self.state}, #{self.country}".gsub(", ,",",")
  end

  def update_cached
    self.update_attribute(:cached_complete_name, self.complete_name)
  end

  private

  def update_cached_complete_name
    unless self.cached_complete_name == self.complete_name
      self.update_cached
    end
  end

  # Expires the cache after a city is modified or added
  def delete_cache
    delete_caches([
      "geo_cities_all_active", 
      "geo_cities_all", 
      'geo_cities_' + country_code, 
      'geo_cities_' + country_code + '_' + (state ? state.parameterize : "")
    ])
  end

end