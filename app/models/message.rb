class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :from, :class_name  => 'User'
end
