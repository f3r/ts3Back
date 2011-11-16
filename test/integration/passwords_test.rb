require 'test_helper'
class PasswordsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @user = Factory(:user)
    end
  end

  should "create new password reset token (xml)" do
    post '/users/password.xml', {:email => @user.email}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

  should "create new password reset token (json)" do
    post '/users/password.json', {:email => @user.email}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not create new password reset token (xml)" do
    post '/users/password.xml', {:email => Faker::Internet.email}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "email", :content => "106" }
  end

  should "update password with reset token (xml)" do
    post '/users/password.xml', {:email => @user.email}
    user = User.first(:order => 'id DESC')
    put '/users/password.xml', {:reset_password_token => user.reset_password_token, :password => "new_password"}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end

  should "update password with reset token (json)" do
    post '/users/password.json', {:email => @user.email}
    user = User.first(:order => 'id DESC')
    put '/users/password.json', {:reset_password_token => user.reset_password_token, :password => "new_password"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not update password with reset token (xml)" do
    post '/users/password.xml', {:email => @user.email}
    user = User.first(:order => 'id DESC')
    put '/users/password.xml', {:reset_password_token => "random_text", :password => "new_password"}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "reset_password_token", :content => "103" }
  end

  should "not update password with empty password (xml)" do
    post '/users/password.xml', {:email => @user.email}
    user = User.first(:order => 'id DESC')
    put '/users/password.xml', {:reset_password_token => user.reset_password_token}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "password", :content => "101" }
  end

end