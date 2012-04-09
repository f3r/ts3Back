class ConversationsController < ApiController

  # == Description
  # Returns the inbox conversations for the current user
  # ==Resource URL
  # /conversations.format
  # ==Example
  # GET https://backend-heypal.heroku.com/conversations.json
  # === Parameters
  # [access_token]
  # == Errors
  # [115] no result
  def index
    @conversations = Messenger.get_conversations(current_user)

    if @conversations.present?
      render 'conversations/index'
    else
      return_message(200, :ok, {:conversations => []})
      #return_message(200, :ok, {:err => {:conversations => [115]}})
    end
  end

  # == Description
  # Returns all the messages with another user and marks conversation as read
  # ==Resource URL
  # /conversations/user.format
  # ==Example
  # GET https://backend-heypal.heroku.com/messages/2.json
  # === Parameters
  # [access_token]
  # [user] The other user in the conversation
  # == Errors
  # [106] User not found
  # [115] no results
  def show
    @conversation, @messages = Messenger.get_conversation_messages(current_user, params[:id])
    Messenger.mark_as_read(current_user, @conversation.id) if @conversation
    if @messages
      render 'conversations/show'
    else
      return_message(200, :ok, {:err => {:messages => [115]}})
    end
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
    @message = Message.new(:body => params[:message])
    if Messenger.add_reply(current_user, params[:id], @message)
      return_message(200, :ok)
    else
      return_message(200, :ok, {:err => {:messages => [106]}})
    end
  end

  # == Description
  # Marks a conversation with another user as unread
  # ==Resource URL
  # /conversations/:id/mark_as_unread.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/conversations/2/mark_as_unread.json
  # === Parameters
  # [access_token]
  # [id]    The id of the conversation
  # == Errors
  # [106] User not found or already read
  def mark_as_unread
    if Messenger.mark_as_unread(current_user, params[:id])
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => {:messages => [106]}})
    end
  end

  # == Description
  # Returns the number of unread conversations for the current user
  # ==Resource URL
  # /conversations/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/conversations/1.json
  # === Parameters
  # [access_token]
  def unread_count
    @status = Messenger.inbox_status(current_user)
    return_message(200, :ok, :count => @status[:unread])
  end
end