class Cmspage < ActiveRecord::Base
  default_scope :order => 'id ASC'
  
   
  validates_presence_of   :page_title, :message => "101"
  validates_presence_of   :page_url, :message => "101"
  
  validates_uniqueness_of :page_url, :message => "Page Already exist with this name"
  
  validates_exclusion_of  :page_url, :in =>["Hong Kong","Sydney","Kuala Lumpur","New York","San Francisco","Los Angeles","Shanghai","Manila"], :message => "Can't use this as page url (city name)"
  
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
end