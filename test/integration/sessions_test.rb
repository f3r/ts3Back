require 'test_helper'
class SessionsTest < ActionController::IntegrationTest

  setup do
    @parameters = { :name => Faker::Name.name, 
                    :email => Faker::Internet.email,
                    :password => "FSls26ESKaaJzADP" }
  end

  should "sign in with email and password and get token (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    user.confirm!
    post '/users/sign_in.xml', {:email => @parameters[:email], :password => @parameters[:password]}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'rsp', :child => {:tag => 'authentication_token', :content => user.authentication_token}
  end

  should "sign in with email and password and get token (json)" do
    assert_difference('User.count') do
      post '/users/sign_up.json', @parameters
    end
    user = User.first(:order => 'id DESC')
    user.confirm!
    post '/users/sign_in.json', {:email => @parameters[:email], :password => @parameters[:password]}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal user.authentication_token, json['authentication_token']
  end

  should "not sign in with email and password (xml)" do
    post '/users/sign_in.xml', {:email => @parameters[:email], :password => @parameters[:password]}
    assert_response(401)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "user", :content => "109" }
  end

  should "not sign in with email and password (json)" do
    post '/users/sign_in.json', {:email => @parameters[:email], :password => @parameters[:password]}
    assert_response(401)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['user'].include? 109)    
  end

end