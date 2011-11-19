require 'test_helper'
class AuthenticationsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin = Factory(:user, :role => "admin")
      @admin.confirm!
      Authorization.current_user = @admin
      @oauth_token = {
        :provider=>"twitter", 
        :uid=>"1111111111", 
        :credentials=>{"token"=>"aaaaa", "secret"=>"bbbbb"}, 
        :user_info=>{"first_name"=>Faker::Name.first_name,"last_name"=>Faker::Name.last_name, "email" => Faker::Internet.email}}
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

      should "list own authentications (json)" do
        get '/authentications.json', {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      end

      should "add provider with access_token and oauth_token (json)" do
        assert_difference 'Authentication.count', +1 do
          post '/authentications.json', {:access_token => @access_token, :oauth_token => @oauth_token}
        end
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        assert_equal @oauth_token[:uid], json['authentication']['uid']
        assert_equal @oauth_token[:provider], json['authentication']['provider']
      end

      should "not add provider without oauth_token (json)" do
        post '/authentications.json', {:access_token => @access_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "fail", json['stat']
        assert (json['err']['oauth_token'].include? 117)
      end

      should "sign in with access_token (json)" do
        assert_difference 'Authentication.count', +1 do
          post '/authentications.json', {:access_token => @access_token, :oauth_token => @oauth_token}
        end
        post '/users/oauth/sign_in.json', {:oauth_token => @oauth_token}
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        assert_equal @access_token, json['authentication_token']
      end

    end
    
  end

  logged_in_as "user" do
  end
  logged_in_as "admin" do
  end
  logged_in_as "agent" do
  end

  should "not sign in without access_token (json)" do
    post '/users/oauth/sign_in.json', {:oauth_token => @oauth_token}
    assert_response(401)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['user'].include? 110)
  end

end