class Comment < ActiveRecord::Base
  belongs_to :place
  belongs_to :user
  
  validates_presence_of [:user_id, :place_id, :comment], :message => "101"
end