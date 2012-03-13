require 'test_helper'
class ReviewsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin = Factory(:user, :role => "admin")
      @admin.confirm!
      Authorization.current_user = @admin
      @published_place = Factory(:published_place, :user => @admin)
      @published_place.publish!
    end
  end

  def self.logged_in_as(role, &block)
    context "logged in as #{role}" do
      setup do
        @user = Factory(:user, :role => role)
        @user.confirm!
        @access_token = @user.authentication_token
      end

      context '' do
        yield
      end

      should "list place reviews (json)" do
        get "/places/#{@published_place.id}/reviews.json", {
          :access_token => @access_token
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      end

      should "create review (json)" do
        post "/places/#{@published_place.id}/reviews.json", {
          :access_token => @access_token,
          :comment => "woo",
          :accuracy => 5,
          :cleanliness => 5,
          :checkin => 5,
          :communication => 5,
          :location => 5,
          :value => 5
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
      end

    end
  end

  logged_in_as "user" do
  end
  logged_in_as "admin" do
  end
  logged_in_as "agent" do
  end
  
end