class City < ActiveRecord::Base
  default_scope :order => 'name ASC'
  has_many :places
end