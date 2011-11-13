require 'test_helper'
class UsersTest < ActionController::IntegrationTest

  setup do
    @user = Factory(:user, :role => "admin")
    @user.confirm!
    Authorization.current_user = @user
    @birthday = "1981/01/01"
  end

  should "show full current user information (json)" do
    get '/users.json', {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @user.id, json['user']['id']
    assert_equal @user.first_name, json['user']['first_name']
  end
  
  should "show full user information (json)" do
    get "/users/#{@user.id}.json", {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @user.id, json['user']['id']
    assert_equal @user.first_name, json['user']['first_name']
  end
  
  should "show full user information (xml)" do
    get '/users.xml', {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => @user.first_name }
  end
  
  should "not show full user information (json)" do
    get '/users.json', {:access_token => "invalid_token"}
    assert_response(401)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['access_token'].include? 105)
  end
  
  should "show user badge info (json)" do
    get "/users/#{@user.id}/info.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @user.id, json['user']['id']
    assert_equal @user.first_name, json['user']['first_name']
  end
  
  should "show user badge info (xml)" do
    get "/users/#{@user.id}/info.xml"
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => @user.first_name }
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
  
  should "update user profile information (json)" do
    put "/users.json", {:access_token => @user.authentication_token, :first_name => "Test Name", :gender => "male" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "male", json['user']['gender']
  end
  
  should "update user profile information (xml)" do
    put "/users.xml", {:access_token => @user.authentication_token, :first_name => "Test Name", :gender => "male" }
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'user', :child => { :tag => "first_name", :content => "Test Name" }
    assert_tag 'user', :child => { :tag => "gender", :content => "male" }
  end
  
  should "not update user profile information, invalid birthdate (json)" do
    put "/users.json", {:access_token => @user.authentication_token, :birthdate => "1111111" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['birthdate'].include? 113)
  end

  should "update user profile information, valid birthdate (json)" do
    put "/users.json", {:access_token => @user.authentication_token, :birthdate => @birthday }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @birthday.to_date, json['user']['birthdate'].to_date
  end
  
  should "update avatar" do
    avatar = fixture_file_upload("test_image.jpg","image/jpg")
    put "/users.json", {:access_token => @user.authentication_token, :avatar => avatar }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['user']['avatar']
  end
  
  should "update avatar using url" do
    put "/users.json", {
      :access_token => @user.authentication_token, 
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
    put "/users/#{@user.id}/change_role.json", {:access_token => @user.authentication_token, :role => "admin" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "not change users role, invalid role (json)" do
    put "/users/#{@user.id}/change_role.json", {:access_token => @user.authentication_token, :role => "troll" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['role'].include? 103)
  end
  
end