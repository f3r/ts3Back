class Address < ActiveRecord::Base
  using_access_control
  belongs_to :user
  validates_presence_of :country, :message => "101"
  validates_presence_of :city, :message => "101"
  validates_presence_of :street, :message => "101"
  validates_presence_of :zip, :message => "101"
  validates_uniqueness_of :country, :scope => [:user_id, :city, :street, :zip], :message => "116"
  validates_uniqueness_of :city, :scope => [:user_id, :country, :street, :zip], :message => "116"
  validates_uniqueness_of :street, :scope => [:user_id, :city, :country, :zip], :message => "116"
  validates_uniqueness_of :zip, :scope => [:user_id, :city, :street, :country], :message => "116"
end