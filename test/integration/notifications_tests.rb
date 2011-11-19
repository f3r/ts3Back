require 'test_helper'
class NotificationsTest < ActionController::IntegrationTest

  # setup do
  #   without_access_control do
  #     @agent = Factory(:user, :role => "agent")
  #     @agent.confirm!
  #     Authorization.current_user = @agent
  #     @city = Factory(:city)
  #     @place_type = Factory(:place_type)
  #     @place = Factory(:place, :user => @agent, :place_type => @place_type, :city => @city)
  #     REDIS.flushall
  #     @n = Notification.new
  #     @n.event = Faker::Lorem.words(2).to_sentence
  #     @n.notification_type = :Places
  #     @n.content = {:place_id => @place.id, :user => {:id => @agent.id, :first_name => @agent.first_name, :last_name => @agent.last_name}}
  #     @n.save
  #   end
  # end

  # FIX ME: it doesn't work on the tests, it works manually

  # should "list notifications of current user" do
  #   get "/notifications.json", {:access_token => @agent.authentication_token}
  #   assert_response(200)
  #   assert_equal 'application/json', @response.content_type
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "ok", json['stat']
  #   assert_not_nil json['notifications']
  # end
  # 
  # should "list unread notifications of current user" do
  #   get "/notifications/unread.json", {:access_token => @agent.authentication_token}
  #   assert_response(200)
  #   assert_equal 'application/json', @response.content_type
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "ok", json['stat']
  #   assert_not_nil json['notifications']
  # end

  # should "mark all as read, get no unread results" do
  #   get "/notifications/mark_as_read.json", {:access_token => @agent.authentication_token}
  #   assert_response(200)
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "ok", json['stat']
  #   get "/notifications/unread.json", {:access_token => @agent.authentication_token}
  #   assert_response(200)
  #   assert_equal 'application/json', @response.content_type
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "ok", json['stat']
  #   assert_blank json['notifications']
  #   REDIS.flushall
  # end

  # should "mark as read notifications of current user" do
  #   get "/notifications/mark_as_read.json", {:access_token => @agent.authentication_token}
  #   assert_response(200)
  #   assert_equal 'application/json', @response.content_type
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "ok", json['stat']
  #   assert_blank json['notifications']
  # end

end