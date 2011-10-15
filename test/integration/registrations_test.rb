require 'test_helper'
class RegistrationsTest < ActionController::IntegrationTest

  setup do
    @parameters = { :name => Faker::Name.name, 
                    :email => Faker::Internet.email, 
                    :password => "FSls26ESKaaJzADP" }
  end

  should "create a user (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    assert_equal @parameters[:name], user.name
    assert_equal @parameters[:email], user.email
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

  should "create a user (json)" do
    assert_difference('User.count') do
      post '/users/sign_up.json', @parameters
    end
    user = User.first(:order => 'id DESC')
    assert_equal @parameters[:name], user.name
    assert_equal @parameters[:email], user.email
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "cancel registration (xml)" do
    assert_difference 'User.count', +1 do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    user.confirm!
    assert_difference 'User.count', -1 do
      delete '/users.xml', {:access_token => user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

  should "cancel registration invalid token (xml)" do
    assert_difference 'User.count', +1 do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    user.confirm!
    assert_no_difference 'User.count' do
      delete '/users.xml', {:access_token => "invalid-token"}
    end
    assert_response(401)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
  end

end