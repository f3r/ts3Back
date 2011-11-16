require 'test_helper'
class UsersTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin_user = Factory(:user, :role => "admin")
      @admin_user.confirm!
      @user = Factory(:user, :role => "user")
      @user.confirm!
      Authorization.current_user = @admin_user
      @birthday = "1981/01/01"
    end
  end

  should "show full current user information (json)" do
    get '/users.json', {:access_token => @admin_user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @admin_user.id, json['user']['id']
    assert_equal @admin_user.first_name, json['user']['first_name']
  end
  
  should "show full user information (json)" do
    get "/users/#{@admin_user.id}.json", {:access_token => @admin_user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @admin_user.id, json['user']['id']
    assert_equal @admin_user.first_name, json['user']['first_name']
  end
  
  should "show full current user information (xml)" do
    get '/users.xml', {:access_token => @admin_user.authentication_token}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => @admin_user.first_name }
  end
  
  should "not show full user information (json)" do
    get '/users.json', {:access_token => "invalid_token"}
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
  end

  should "show full user information as admin (xml)" do
    get "/users/#{@user.id}.xml", {:access_token => @admin_user.authentication_token}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => @user.first_name }
  end

  should "not show full user information as user (xml)" do
    get "/users/#{@admin_user.id}.xml", {:access_token => @user.authentication_token}
    assert_response(403)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "permissions", :content => "134" }
  end
  
  should "show user badge info (json)" do
    get "/users/#{@admin_user.id}/info.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @admin_user.id, json['user']['id']
    assert_equal @admin_user.first_name, json['user']['first_name']
  end
  
  should "show user badge info (xml)" do
    get "/users/#{@admin_user.id}/info.xml"
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => @admin_user.first_name }
  end
  
  should "not show user badge info (json)" do
    get "/users/10000000/info.json"
    assert_response(404)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['record'].include? 106)
  end
  
  should "update current user profile information (json)" do
    put "/users.json", {:access_token => @admin_user.authentication_token, :first_name => "Test Name", :gender => "male" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "male", json['user']['gender']
  end
  
  should "update current user profile information (xml)" do
    put "/users.xml", {:access_token => @admin_user.authentication_token, :first_name => "Test Name", :gender => "male" }
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => "Test Name" }
    assert_tag 'user', :child => { :tag => "gender", :content => "male" }
  end

  should "update user profile information as admin (xml)" do
    put "/users/#{@user.id}.xml", {:access_token => @admin_user.authentication_token, :first_name => "Test Name", :gender => "male" }
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => "Test Name" }
    assert_tag 'user', :child => { :tag => "gender", :content => "male" }
  end

  should "not update admin user profile information as user (xml)" do
    put "/users/#{@admin_user.id}.xml", {:access_token => @user.authentication_token, :first_name => "Test Name", :gender => "male" }
    assert_response(403)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "permissions", :content => "134" }
  end
    
  should "not update current user profile information, invalid birthdate (json)" do
    put "/users.json", {:access_token => @admin_user.authentication_token, :birthdate => "1111111" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['birthdate'].include? 113)
  end
  
  should "update user profile information, valid birthdate (json)" do
    put "/users.json", {:access_token => @admin_user.authentication_token, :birthdate => @birthday }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @birthday.to_date, json['user']['birthdate'].to_date
  end
  
  should "update avatar" do
    avatar = fixture_file_upload("test_image.jpg","image/jpg")
    put "/users.json", {:access_token => @admin_user.authentication_token, :avatar => avatar }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['user']['avatar']
  end
  
  should "update avatar using url" do
    put "/users.json", {
      :access_token => @admin_user.authentication_token, 
      :avatar_url => "http://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Lamprotornis_hildebrandti_-Tanzania-8-2c.jpg/470px-Lamprotornis_hildebrandti_-Tanzania-8-2c.jpg"
    }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['user']['avatar']
  end

  should "change users role (json)" do
    put "/users/#{@user.id}/change_role.json", {:access_token => @admin_user.authentication_token, :role => "admin" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "not change users role, invalid role (json)" do
    put "/users/#{@user.id}/change_role.json", {:access_token => @admin_user.authentication_token, :role => "troll" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['role'].include? 103)
  end

end