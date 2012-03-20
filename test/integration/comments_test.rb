require 'test_helper'
class CommentsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @agent_user = Factory(:user, :role => "agent")
      Authorization.current_user = @agent_user
      @admin_user = Factory(:user, :role => "admin")
      @user = Factory(:user, :role => "user")

      @place      = Factory(:published_place, :user => @agent_user, :published => false)
      @comment    = Factory(:comment, :place => @place, :user => @agent_user)

      @published_place = Factory( 
        :published_place, 
        :user => @agent_user
      )
      @published_place_2 = Factory( 
        :published_place,
        :user => @agent_user
      )

      @published_comment   = Factory(:comment, :place => @published_place,   :user => @user)
      @published_reply     = Factory(:comment, :place => @published_place,   :user => @user, :replying_to => @published_comment.id)
      @published_2_comment = Factory(:comment, :place => @published_place_2, :user => @user)
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
      post "/places/#{@published_place.id}/comments.json", { :comment => "testing", :access_token => @user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok",      json['stat']
    assert_equal "testing", json['comment']['comment']
  end
  
  should "not reply a comment as user (json)" do
    post "/places/#{@published_place.id}/comments.json", { :comment => "testing", :replying_to => @published_comment.id, :access_token => @user.authentication_token }
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

  should "list answered comments as guest on a published place with comments" do
    get "/places/#{@published_place.id}/comments.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_operator json['comments'].count, :>, 0
  end

  should "not list comments as guest on a published place with unanswered comments" do
    get "/places/#{@published_place_2.id}/comments.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert (json['err']['comments'].include? 115)
  end

  should "list comments as owner on a published place with unanswered comments" do
    get "/places/#{@published_place_2.id}/comments.json", { :access_token => @agent_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_operator json['comments'].count, :>, 0
  end
end