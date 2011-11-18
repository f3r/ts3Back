class Comment < ActiveRecord::Base
  using_access_control
  belongs_to :place
  belongs_to :user
  
  validates_presence_of [:user_id, :place_id, :comment], :message => "101"  

  validate :validates_replying_to

  # Checks if the replying_to id exists or not
  def validates_replying_to
      self['replying_to'] and Comment.find(self['replying_to']).blank?
  end
end