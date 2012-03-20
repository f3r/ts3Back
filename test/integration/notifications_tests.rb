require 'test_helper'
class NotificationsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      REDIS.flushall
      @agent = Factory(:user, :role => "agent")
      Authorization.current_user = @agent
      @user = Factory(:user, :role => "user")
      @city = Factory(:city)
      @place_type = Factory(:place_type)
      @place = Factory(:place, :user => @agent, :place_type => @place_type, :city => @city)
    end
  end

  should "list notifications of current user" do
    @n = Notification.new
    @n.event = Faker::Lorem.words(2).to_sentence
    @n.notification_type = :Places
    @n.content = {:place_id => @place.id, :user => {:id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name}}
    @n.save
    get "/notifications.json", {:access_token => @agent.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['notifications']
    assert_operator json['notifications'].count, :>=, 1
  end
  
  should "list unread notifications of current user" do
    @n = Notification.new
    @n.event = Faker::Lorem.words(2).to_sentence
    @n.notification_type = :Places
    @n.content = {:place_id => @place.id, :user => {:id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name}}
    @n.save
    get "/notifications/unread.json", {:access_token => @agent.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['notifications']
    assert_operator json['notifications'].count, :>=, 1
  end

  should "mark all as read, get no unread results" do
    @n = Notification.new
    @n.event = Faker::Lorem.words(2).to_sentence
    @n.notification_type = :Places
    @n.content = {:place_id => @place.id, :user => {:id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name}}
    @n.save

    get "/notifications/mark_as_read.json", {:access_token => @agent.authentication_token}
    assert_response(200)
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']

    get "/notifications/unread.json", {:access_token => @agent.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_blank json['notifications']
  end

  should "mark as read notifications of current user" do
    @n = Notification.new
    @n.event = Faker::Lorem.words(2).to_sentence
    @n.notification_type = :Places
    @n.content = {:place_id => @place.id, :user => {:id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name}}
    @n.save
    get "/notifications/mark_as_read.json", {:access_token => @agent.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_blank json['notifications']
  end

end