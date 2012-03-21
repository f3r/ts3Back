class ConversationsController < ApiController
  # All the conversations in the user inbox
  def index
    @conversations = Messenger.get_conversations(current_user)
    @conversations.collect do |c|
      {
        :name => c.name,
        :bla => c.super_metodo_loco(current_user.currency)
      }
    end
    # Rabl (?) para renderear JSON
  end

  # All the messages for one conversation
  def show
    @conversation, @messages = Messenger.get_conversation_messages(current_user, params[:id])
    # Rabl (?) para renderear JSON
  end

  # Start a new conversation
  # def create
  #   @inquiry = Inquiry.create(params[:inquiry])
  #   @conversation = Conversation.new(:recipient => @inquiry.recipient, :body => @inquiry.message)
  #   @conversation.target = @inquiry
  # 
  #   Messenger.start_conversation(current_user, @conversation)
  # end

  # Add a reply to a conversation
  def update
    @message = Message.new(params[:message])
    Messenger.add_reply(current_user, params[:conversation_id], @message)
  end

  # Mark a conversation as unread
  def mark_as_unread
    Messenger.mark_as_unread(current_user, params[:conversation_id])
  end

  # Counts the number of unread messages
  def unread_count
    @status = Messenger.inbox_status(current_user)
    # Rabl (?) para renderear JSON
  end
end