class Cmspage < ActiveRecord::Base
  default_scope :order => 'id ASC'
  
   
  validates_presence_of   :page_title, :message => "101"
  validates_presence_of   :page_url, :message => "101"
  
  validates_uniqueness_of :page_url, :message => "Page Already exist with this name"
  
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