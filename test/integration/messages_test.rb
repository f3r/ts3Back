require 'test_helper'
class MessagesTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      REDIS.flushall
      @admin = Factory(:user, :role => "admin")
      Authorization.current_user = @admin
    end
  end

  def self.logged_in_as(role, &block)
    context "logged in as #{role}" do
      setup do
        @user = Factory(:user, :role => role)
        @access_token = @user.authentication_token
        @user_2 = Factory(:user, :role => role)
        @access_token_2 = @user_2.authentication_token
      end

      context '' do
        yield
      end

      should "list conversations (json)" do
        get '/conversations.json', {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      end

      should "create message (json)" do
        post "/messages/#{@user_2.id}.json", {:access_token => @access_token, :message => "hello"}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      end
      
      should "create and destroy a message (json)" do
        post "/messages/#{@user_2.id}.json", {:access_token => @access_token, :message => "hello"}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        delete "/conversations/#{@user_2.id}.json", {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      end

      should "create and mark as read a conversation (json)" do
        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello"}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        get "/conversations/unread_count.json", {:access_token => @access_token}
        json = ActiveSupport::JSON.decode(response.body)
        assert_operator json['count'], :>=, 1
        put "/conversations/#{@user_2.id}/mark_as_read.json", {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        get "/conversations/unread_count.json", {:access_token => @access_token}
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal 0, json['count']
      end
      
      should "create and mark as read and mark as unread a conversation (json)" do
        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello"}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      
        get "/conversations/unread_count.json", {:access_token => @access_token}
        json = ActiveSupport::JSON.decode(response.body)
        assert_operator json['count'], :>=, 1
      
        put "/conversations/#{@user_2.id}/mark_as_read.json", {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      
        get "/conversations/unread_count.json", {:access_token => @access_token}
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal 0, json['count']
      
        put "/conversations/#{@user_2.id}/mark_as_unread.json", {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      
        get "/conversations/unread_count.json", {:access_token => @access_token}
        json = ActiveSupport::JSON.decode(response.body)
        assert_operator json['count'], :>=, 1
      
      end
      
      should "get message and check unread count (json)" do
        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello"}
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        get "/conversations/unread_count.json", {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        assert_operator json['count'], :>=, 1
      end

      should "get messages with user (json)" do
        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello"}
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal "ok", json['stat']
        post "/messages/#{@user.id}.json", {:access_token => @access_token_2, :message => "hello2"}
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal "ok", json['stat']
        get "/messages/#{@user_2.id}.json", {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        assert_operator json['messages'].count, :>=, 2
      end

    end
  end

  logged_in_as "user" do
  end
  logged_in_as "admin" do
  end
  logged_in_as "agent" do
  end

end