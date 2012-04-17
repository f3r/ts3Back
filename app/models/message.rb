class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :from, :class_name  => 'User'

  def system_msg_id
    msg_id = read_attribute(:system_msg_id)
    msg_id.to_sym if msg_id
  end
end
