require 'test_helper'
class MessagesTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin = Factory(:user, :role => "admin")
      @admin.confirm!
      Authorization.current_user = @admin
    end
  end

  def self.logged_in_as(role, &block)
    context "logged in as #{role}" do
      setup do
        @user = Factory(:user, :role => role)
        @user.confirm!
        @access_token = @user.authentication_token
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

      # REDIS.flushall
    end
  end

  logged_in_as "user" do
  end
  logged_in_as "admin" do
  end
  logged_in_as "agent" do
  end

end