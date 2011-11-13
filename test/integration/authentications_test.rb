require 'test_helper'
class AuthenticationsTest < ActionController::IntegrationTest

  setup do
    @user = Factory(:user, :role => "admin")
    @user.confirm!
    Authorization.current_user = @user
    @oauth_token = {
      :provider=>"twitter", 
      :uid=>"1111111111", 
      :credentials=>{"token"=>"aaaaa", "secret"=>"bbbbb"}, 
      :user_info=>{"first_name"=>Faker::Name.first_name,"last_name"=>Faker::Name.last_name, "email" => Faker::Internet.email}}
  end

  should "list user authentications (json)" do
    get '/authentications.json', {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
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

  should "add provider with access_token and oauth_token (json)" do
    assert_difference 'Authentication.count', +1 do
      post '/authentications.json', {:access_token => @user.authentication_token, :oauth_token => @oauth_token}
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
    post '/authentications.json', {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['oauth_token'].include? 117)
  end

  should "sign in with access_token (json)" do
    assert_difference 'Authentication.count', +1 do
      post '/authentications.json', {:access_token => @user.authentication_token, :oauth_token => @oauth_token}
    end
    post '/users/oauth/sign_in.json', {:oauth_token => @oauth_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @user.authentication_token, json['authentication_token']
  end

end