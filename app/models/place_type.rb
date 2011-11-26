class PlaceType < ActiveRecord::Base
  using_access_control
  validates_uniqueness_of :name, :message => "100"
  validates_presence_of :name, :message => "101"
  attr_accessible :name
  has_many :places
  after_commit  :delete_cache

  def self.all_cached
    Rails.cache.fetch('place_types_list') { PlaceType.all }
  end
  
  private

  def delete_cache
    Rails.cache.delete("place_types_list")
  end

end