require 'test_helper'
class MessagesTest < ActionController::IntegrationTest

  setup do
    @consumer = Factory(:user, :role => "user")
    @agent = Factory(:user, :role => "agent")
    # Consumer user will have one message on his inbox:
    @inbox_entry = Factory(:inbox_entry, :user => @consumer)
  end

  should "check unread count (json)" do
    get "/conversations/unread_count.json", {:access_token => @consumer.authentication_token}
    json = json_response_ok
    puts json
    assert_equal "ok", json['stat']
    assert_equal 1, json['count']
  end

  should "list conversations (json)" do
    get '/conversations.json', {:access_token => @consumer.authentication_token}
    json = json_response_ok
    conversations = json['conversations']
    assert_equal 1, conversations.size
  end

  should "list conversation messages and mark the conversation as read (json)" do
    @conversation = @inbox_entry.conversation
    assert !@inbox_entry.read

    get "/conversations/#{@conversation.id}.json", {:access_token => @consumer.authentication_token}
    json = json_response_ok
    conversations = json['messages']
    assert_equal 1, conversations.size

    @inbox_entry.reload
    assert @inbox_entry.read
  end

  should "mark as unread a conversation (json)" do
    @conversation = @inbox_entry.conversation
    put "/conversations/#{@conversation.id}/mark_as_unread.json", {:access_token => @consumer.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']

    get "/conversations/unread_count.json", {:access_token => @consumer.authentication_token}
    json = ActiveSupport::JSON.decode(response.body)
    assert_operator json['count'], :>=, 1
  end

  # def self.logged_in_as(role, &block)
  #    context "logged in as #{role}" do
  #      context '' do
  #        yield
  #      end
  # 
  #      should "get messages with user (json)" do
  #        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello"}
  #        json = ActiveSupport::JSON.decode(response.body)
  #        assert_equal "ok", json['stat']
  #        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello2"}
  #        json = ActiveSupport::JSON.decode(response.body)
  #        assert_equal "ok", json['stat']
  #        get "/messages/#{@user_2.id}.json", {:access_token => @access_token}
  #        assert_response(200)
  #        assert_equal 'application/json', @response.content_type
  #        json = ActiveSupport::JSON.decode(response.body)
  #        assert_kind_of Hash, json
  #        assert_equal "ok", json['stat']
  #        assert_operator json['messages'].count, :>=, 2
  #      end

      # should "create message (json)" do
      #   post "/conversations/#{@user_2.id}.json", {:access_token => @access_token, :message => "hello"}
      #   assert_response(200)
      #   assert_equal 'application/json', @response.content_type
      #   json = ActiveSupport::JSON.decode(response.body)
      #   assert_kind_of Hash, json
      #   assert_equal "ok", json['stat']
      # end
      
      # should "destroy a message (json)" do
      #   delete "/conversations/#{@user_2.id}.json", {:access_token => @access_token}
      #   assert_response(200)
      #   assert_equal 'application/json', @response.content_type
      #   json = ActiveSupport::JSON.decode(response.body)
      #   assert_kind_of Hash, json
      #   assert_equal "ok", json['stat']
      # end

      # should "create and mark as read a conversation (json)" do
      #   post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello"}
      #   assert_response(200)
      #   assert_equal 'application/json', @response.content_type
      #   json = ActiveSupport::JSON.decode(response.body)
      #   assert_kind_of Hash, json
      #   assert_equal "ok", json['stat']
      #   get "/conversations/unread_count.json", {:access_token => @access_token}
      #   json = ActiveSupport::JSON.decode(response.body)
      #   assert_operator json['count'], :>=, 1
      #   put "/conversations/#{@user_2.id}/mark_as_read.json", {:access_token => @access_token}
      #   assert_response(200)
      #   assert_equal 'application/json', @response.content_type
      #   json = ActiveSupport::JSON.decode(response.body)
      #   assert_kind_of Hash, json
      #   assert_equal "ok", json['stat']
      #   get "/conversations/unread_count.json", {:access_token => @access_token}
      #   json = ActiveSupport::JSON.decode(response.body)
      #   assert_equal 0, json['count']
      # end
  #   end
  # end
  # 
  # logged_in_as "user" do
  # end
  #logged_in_as "admin" do
  #end
  #logged_in_as "agent" do
  #end

end