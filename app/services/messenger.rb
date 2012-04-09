class Messenger
  def self.get_conversations(user)
    inbox_entries = InboxEntry.where(:user_id => user.id, :deleted_at => nil).all(:include => [:conversation])
    conversations = []
    inbox_entries.each do |inbox_entry|
      conversation = inbox_entry.conversation
      conversation.from = conversation.other_party(user)
      conversation.body = conversation.first_message.body
      conversation.read = inbox_entry.read
      conversations << conversation
    end
    conversations
  end

  def self.get_conversation_messages(user, conversation_id)
    inbox_entry = InboxEntry.where(:user_id => user.id, :conversation_id => conversation_id).first!
    conversation = inbox_entry.conversation
    [conversation, conversation.messages]
  end

  def self.start_conversation(sender, conversation)
    return false unless sender && conversation
    conversation.sender = sender
    return false unless conversation.valid?

    recipient = conversation.recipient
    return false unless recipient && recipient != sender

    # Create the conversation
    conversation.save!
    first_message = conversation.messages.build(:body => conversation.body, :from => sender)
    first_message.save!

    # Insert it into inboxes
    InboxEntry.create!(:conversation => conversation, :user => sender, :read => true)
    InboxEntry.create!(:conversation => conversation, :user => recipient)

    return true
  end

  def self.add_reply(user, conversation_id, message)
    return false unless message.valid?

    sender_inbox_entry = InboxEntry.where(:user_id => user.id, :conversation_id => conversation_id).first!
    conversation = sender_inbox_entry.conversation

    message.from = user
    conversation.messages << message

    recipient_inbox_entry = sender_inbox_entry.other_party
    recipient_inbox_entry.mark_as_unread
    recipient_inbox_entry.save!
  end

  def self.mark_as_read(user, conversation_id)
    inbox_entry = InboxEntry.where(:user_id => user.id, :conversation_id => conversation_id).first!
    inbox_entry.mark_as_read
    inbox_entry.save!
  end

  def self.mark_as_unread(user, conversation_id)
    inbox_entry = InboxEntry.where(:user_id => user.id, :conversation_id => conversation_id).first!
    inbox_entry.mark_as_unread
    inbox_entry.save!
  end

  def self.inbox_status(user)
    conditions = {:user_id => user.id, :deleted_at => nil}
    total = InboxEntry.where(conditions).count
    unread = InboxEntry.where(conditions).where(:read => false).count

    {:total => total, :unread => unread}
  end
end