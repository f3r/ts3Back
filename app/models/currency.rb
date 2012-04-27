class Currency < ActiveRecord::Base
  default_scope :order => 'name ASC'
  
   
  validates_presence_of   :name, :message => "101"
  validates_presence_of   :symbol, :message => "101"
  
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