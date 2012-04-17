require 'test_helper'

class MessengerTest < ActiveSupport::TestCase
  setup do
    @consumer = Factory(:user, :role => "user")
    @agent = Factory(:user, :role => "agent")
  end

  context "New users" do
    should "start with empty inboxes" do
      assert Messenger.get_conversations(@consumer).empty?
      assert Messenger.get_conversations(@agent).empty?
    end
  end

  context "Conversation validations" do
    setup do
      @conversation = Conversation.new
      @conversation.recipient = @agent
      @conversation.body = 'I am interested in your apartment'
    end

    should "require a sender" do
      assert !Messenger.start_conversation(nil, @conversation)
    end

    should "require a recipient" do
      @conversation.recipient = nil
      assert !Messenger.start_conversation(@consumer, @conversation)
    end

    should "not send to self" do
      @conversation.recipient = @consumer
      assert !Messenger.start_conversation(@consumer, @conversation)
    end
  end

  context "New conversation" do
    setup do
      @conversation = Conversation.new
      @conversation.recipient = @agent
      @conversation.body = 'I am interested in your apartment'
    end

    should "deliver the message to the recipient" do
      assert Messenger.start_conversation(@consumer, @conversation)
      conversations = Messenger.get_conversations(@agent)
      assert_equal 1, conversations.size
      #same_message?(conversation, @conversation).should be_true
    end

    should "toggle message read/unread" do
      assert Messenger.start_conversation(@consumer, @conversation)
      sender_conversation = Messenger.get_conversations(@consumer).first
      assert sender_conversation.read?
      conversation = Messenger.get_conversations(@agent).first
      assert !conversation.read?

      # Agent reads the message
      Messenger.mark_as_read(@agent, conversation.id)
      conversation = Messenger.get_conversations(@agent).first
      assert conversation.read?

      # Agent marks the message as unread
      Messenger.mark_as_unread(@agent, conversation.id)
      conversation = Messenger.get_conversations(@agent).first
      assert !conversation.read?
    end

    should "include a default message based on the target" do
      @conversation.body = ''
      @conversation.target = Factory(:inquiry)
      assert Messenger.start_conversation(@consumer, @conversation)
      conversation, messages = Messenger.get_conversation_messages(@consumer, Conversation.last.id)
      assert_equal 1, messages.size
      message = messages.first
      assert_equal :send, message.system_msg_id
      assert message.system
    end

    # it "should deliver reply to recipients that deleted the message" do
    #   # Sheldon deletes the message
    #   conversation = Messenger.get_conversations(sheldon, {}).first
    #   Messenger.delete(sheldon, conversation.id)
    #   Messenger.get_conversations(sheldon, {}).should be_empty
    # 
    #   # Penny replies
    #   @reply = Presenters::Message.new(:body => "Yeah, lets do it!")
    #   Messenger.add_reply(penny, conversation.id, @reply)
    # 
    #   # Sheldon receives it
    #   conversation = Messenger.get_conversations(sheldon, {}).first
    #   same_message?(conversation, @conversation).should be_true
    #   conversation.should be_unread
    # end
  end

  context "Conversation messages" do
    setup do
      @conversation = Conversation.new
      @conversation.recipient = @agent
      @conversation.body = 'I am interested in your apartment'
      Messenger.start_conversation(@consumer, @conversation)
    end

    should "start with one message" do
      conversation, messages = Messenger.get_conversation_messages(@agent, @conversation.id)
      assert_equal 1, messages.size
      msg = messages.first
      assert_equal @conversation.body, msg.body
      assert_equal @consumer, msg.from
    end

    should "add a reply message" do
      conversation = Messenger.get_conversations(@agent).first

      UserMailer.expects(:new_message_reply).returns(mock(:deliver => true))

      # Agent replies
      conversation = Messenger.get_conversations(@agent).first
      reply = Message.new(:body => "It is interesting, I know")
      Messenger.add_reply(@agent, conversation.id, reply)

      conversation = Messenger.get_conversations(@consumer).first
      assert !conversation.read?

      conversation, messages = Messenger.get_conversation_messages(@consumer, @conversation.id)
      assert_equal 2, messages.size
      msg2 = messages.last
      assert_equal reply.body, msg2.body
      assert_equal @agent, msg2.from
    end

    should "send system message" do
      Messenger.add_system_message(@conversation.id, :inquiry_sent)
      conversation, messages = Messenger.get_conversation_messages(@consumer, @conversation.id)

      assert_equal 2, messages.size
      msg = messages.last

      assert msg.system?
      assert_equal :inquiry_sent, msg.system_msg_id.to_sym
    end
  end

  context "Inbox status" do
    setup do
      @conversation = Conversation.new
      @conversation.recipient = @agent
      @conversation.body = 'I am interested in your apartment'
    end

    should "start with empty inbox" do
      status = Messenger.inbox_status(@agent)
      assert_equal 0, status[:total]
      assert_equal 0, status[:unread]
    end

    should "update when receiving" do
      Messenger.start_conversation(@consumer, @conversation)
      status = Messenger.inbox_status(@agent)
      assert_equal 1, status[:total]
      assert_equal 1, status[:unread]
    end

    should "update when marking as read" do
      Messenger.start_conversation(@consumer, @conversation)
      conversation = Messenger.get_conversations(@agent).first
      Messenger.mark_as_read(@agent, conversation.id)
      status = Messenger.inbox_status(@agent)
      assert_equal 1, status[:total]
      assert_equal 0, status[:unread]
    end

    #should "update when deleting" do
      #Messenger.delete(@agent, conversation.id)
      #status = Messenger.inbox_status(@agent)
      #assert_equal 0, status[:total]
      #assert_equal 0, status[:unread]
    #end
  end

  context "Target" do
    setup do
      @conversation = Conversation.new
      @conversation.recipient = @agent
      @conversation.body = 'I am interested in your apartment'
    end

    should "support filtering" do
      inquiry = Inquiry.new(:id => 32)

      @conversation.target = inquiry
      assert Messenger.start_conversation(@consumer, @conversation)

      Messenger.get_conversations(@agent, :target => inquiry)
    end
  end
end