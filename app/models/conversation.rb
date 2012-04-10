class Conversation < ActiveRecord::Base
  belongs_to :sender, :class_name  => 'User'
  belongs_to :target, :polymorphic => true

  has_many :messages
  has_many :inbox_entries

  attr_accessor :recipient, :body, :read, :from

  validates_presence_of :sender

  def read?
    self.read
  end

  def first_message
    self.messages.first
  end

  def other_party(user)
    ie = self.inbox_entries.where(['user_id <> ?', user.id]).first
    ie.user if ie
  end

  # def recipient_inbox_entry
  #    self.inbox_entries.where(['user_id <> ?', self.sender_id]).first
  #  end
end
