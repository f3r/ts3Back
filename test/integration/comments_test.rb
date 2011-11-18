require 'test_helper'
class CommentsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @city    = Factory(:city)
      @agent_user = Factory(:user, :role => "agent")
      @agent_user.confirm!
      Authorization.current_user = @agent_user
      @admin_user = Factory(:user, :role => "admin")
      @admin_user.confirm!
      @user = Factory(:user, :role => "user")
      @user.confirm!
      @place_type = Factory(:place_type)
      @place      = Factory(:place, :user => @agent_user, :place_type => @place_type, :city => @city)
      @comment    = Factory(:comment, :place => @place, :user => @agent_user)
    end
  end

  should "create a comment as owner agent (xml)" do
    assert_difference('Comment.count') do
      post "/places/#{@place.id}/comments.xml", { :comment => "testing", :access_token => @agent_user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp',     :child => { :tag => "stat",    :content => "ok" }
    assert_tag 'comment', :child => { :tag => "comment", :content => "testing" }
  end
  
  should "create a comment as owner agent (json)" do
    assert_difference('Comment.count') do
      post "/places/#{@place.id}/comments.json", { :comment => "testing", :access_token => @agent_user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok",      json['stat']
    assert_equal "testing", json['comment']['comment']
  end

  should "create a comment as user (json)" do
    assert_difference('Comment.count') do
      post "/places/#{@place.id}/comments.json", { :comment => "testing", :access_token => @user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok",      json['stat']
    assert_equal "testing", json['comment']['comment']
  end
  
  should "not reply a comment as user (json)" do
    post "/places/#{@place.id}/comments.json", { :comment => "testing", :replying_to => @comment.id, :access_token => @user.authentication_token }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail",      json['stat']
  end

  should "reply a comment as admin (json)" do
    assert_difference('Comment.count') do
      post "/places/#{@place.id}/comments.json", { :comment => "testing", :replying_to => @comment.id, :access_token => @admin_user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok",      json['stat']
    assert_equal "testing", json['comment']['comment']
  end
  
  should "not create comment, invalid place (json)" do
    post "/places/#{@place.id+1000}/comments.json", { :comment => "testing", :access_token => @agent_user.authentication_token }
    assert_response(404)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [106],  json['err']['record']
  end
  
  should "not create comment, invalid replying_to comment (json)" do
    post "/places/#{@place.id}/comments.json", { :comment => "testing", :replying_to => 1000, :access_token => @agent_user.authentication_token }
    assert_response(404)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['record'].include? 106)
  end

  should "update a comment as agent (json)" do
    put "/places/#{@place.id}/comments/#{@comment.id}.json", { :comment => "NeW Comment", :access_token => @agent_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok",          json['stat']
    assert_equal "NeW Comment", json['comment']['comment']
  end

  should "update a comment as admin (json)" do
    put "/places/#{@place.id}/comments/#{@comment.id}.json", { :comment => "NeW Comment", :access_token => @admin_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok",          json['stat']
    assert_equal "NeW Comment", json['comment']['comment']
  end

  should "not update a comment as user (json)" do
    put "/places/#{@place.id}/comments/#{@comment.id}.json", { :comment => "NeW Comment", :access_token => @user.authentication_token }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail",          json['stat']
    assert (json['err']['authorization'].include? 133)
  end

  should "destroy a comment as agent (json)" do
    delete "/places/#{@place.id}/comments/#{@comment.id}.json", { :access_token => @agent_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "destroy a comment and it's replies as agent (json)" do
    post "/places/#{@place.id}/comments.json", { :comment => "testing", :replying_to => @comment.id, :access_token => @agent_user.authentication_token }
    assert_difference('Comment.count',-2) do
      delete "/places/#{@place.id}/comments/#{@comment.id}.json", { :access_token => @agent_user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "destroy a comment and it's replies as admin (json)" do
    post "/places/#{@place.id}/comments.json", { :comment => "testing", :replying_to => @comment.id, :access_token => @admin_user.authentication_token }
    assert_difference('Comment.count',-2) do
      delete "/places/#{@place.id}/comments/#{@comment.id}.json", { :access_token => @admin_user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not destroy a comment and it's replies as user (json)" do
    post "/places/#{@place.id}/comments.json", { :comment => "testing", :replying_to => @comment.id, :access_token => @user.authentication_token }
    delete "/places/#{@place.id}/comments/#{@comment.id}.json", { :access_token => @user.authentication_token }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

end