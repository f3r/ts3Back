require 'test_helper'
class RegistrationsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @user = Factory(:user, :role => "user")
      @user.confirm!
      Authorization.current_user = @user
      @parameters = { :first_name => Faker::Name.first_name, 
                      :last_name => Faker::Name.last_name, 
                      :email => Faker::Internet.email, 
                      :password => "FSls26ESKaaJzADP" }
    end
  end

  should "create a user (xml)" do
    assert_difference('User.count') do
      post '/users/sign_up.xml', @parameters
    end
    user = User.first(:order => 'id DESC')
    assert_equal @parameters[:first_name], user.first_name
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
    assert_equal @parameters[:first_name], user.first_name
    assert_equal @parameters[:email], user.email
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "cancel registration (xml)" do
    assert_difference 'User.count', -1 do
      delete '/users.xml', {:access_token => @user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

  should "cancel registration invalid token (xml)" do
    assert_no_difference 'User.count' do
      delete '/users.xml', {:access_token => "invalid-token"}
    end
    assert_response(401)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
  end

  should "check email availability, taken (json)" do
    get '/users/check_email.json', {:email => @user.email}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['email'].include? 100)
  end

  should "check email availability, available (json)" do
    get '/users/check_email.json', {:email => Faker::Internet.email}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "check email availability, taken (xml)" do
    get '/users/check_email.xml', {:email => @user.email}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "email", :content => "100" }
  end

  should "check email availability, available (xml)" do
    get '/users/check_email.xml', {:email => Faker::Internet.email}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

end