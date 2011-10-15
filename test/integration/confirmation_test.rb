require 'test_helper'
class ConfirmationsTest < ActionController::IntegrationTest

  setup do
    @parameters = { :name => Faker::Name.name, 
                    :email => Faker::Internet.email, 
                    :password => "FSls26ESKaaJzADP" }
  end

  should "create new confirmation token (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    post '/users/confirmation.xml', {:email => @parameters[:email]}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

  should "create new confirmation token (json)" do
    assert_difference('User.count') do
      post '/users/sign_up.json', @parameters
    end
    user = User.first(:order => 'id DESC')
    post '/users/confirmation.json', {:email => @parameters[:email]}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not create new confirmation token (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    post '/users/confirmation.xml', {:email => "user@example.com"}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
  end

  should "confirm account (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    get '/users/confirmation.xml', {:confirmation_token => user.confirmation_token}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => {:tag => 'authentication_token', :content => user.authentication_token}
  end

  should "confirm account (json)" do
    assert_difference('User.count') do
      post '/users/sign_up.json', @parameters
    end
    user = User.first(:order => 'id DESC')
    get '/users/confirmation.json', {:confirmation_token => user.confirmation_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal user.authentication_token, json['user']['authentication_token']
  end

  should "no confirm account (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    get '/users/confirmation.xml', {:confirmation_token => "invalid-token"}
    assert_response(401)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
  end

end