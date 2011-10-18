require 'test_helper'
class AuthenticationsTest < ActionController::IntegrationTest

  setup do
    @user = Factory(:user)
    @oauth_token = {
      :provider=>"twitter", 
      :uid=>"1111111111", 
      :credentials=>{"token"=>"aaaaa", "secret"=>"bbbbb"}, 
      :user_info=>{"name"=>Faker::Name.name, "email" => Faker::Internet.email}}
  end

  should "list user authentications (json)" do
    @user.confirm!
    get '/users/authentications.json', {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not sign in without access_token (json)" do
    @user.confirm!
    post '/users/twitter/sign_in.json'
    assert_response(401)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['user'].include? 110)
  end

  should "add provider with access_token and oauth_token (json)" do
    @user.confirm!
    post '/users/twitter/sign_in.json', {:access_token => @user.authentication_token, :oauth_token => @oauth_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not sign in with oauth_token and without access_token (json)" do
    @user.confirm!
    post '/users/twitter/sign_in.json', {:oauth_token => @oauth_token}
    assert_response(401)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
  end

end