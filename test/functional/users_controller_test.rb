require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @request.accept = 'application/json'
    without_access_control do
      @user = Factory(:user)
    end
     
    @emails = ActionMailer::Base.deliveries = []
  end
  
  test "sends feedback from user" do
    post :feedback, { :access_token => @user.authentication_token,
      :type => 'city_suggestion',
      :message => 'Buenos Aires'
    }
    
    assert_ok
    assert_equal @emails.size, 1
    email = @emails.first
    assert_equal "User Feedback (city_suggestion)",  email.subject
    assert email.body.include?(@user.full_name)
  end
  
  test "sends feedback from guest" do
    post :feedback, {
      :type => 'city_suggestion',
      :message => 'Buenos Aires'
    }
    
    assert_ok
    assert_equal @emails.size, 1
    email = @emails.first
    assert_equal "User Feedback (city_suggestion)",  email.subject
    assert email.body.include?('Guest User')
  end
  
  def assert_ok
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
end
