class PlaceType < ActiveRecord::Base
  validates_uniqueness_of :name, :message => "100"
  validates_presence_of :name, :message => "101"
  attr_accessible :name
  has_many :places
end