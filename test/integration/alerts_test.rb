require 'test_helper'
class AlertsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin = Factory(:user, :role => "admin")
      @user = Factory(:user, :role => "user")
      Authorization.current_user = @admin
      @fake_alert = {
        :schedule => "daily",
        :alert_type => "Place",
        :delivery_method => "sms",
        :query => {:test => "test", :test2 => "test2", :test3 => "test3"}
      }
    end
  end

  def self.logged_in_as(role, &block)
    context "logged in as #{role}" do
      setup do
        without_access_control do
          @user = Factory(:user, :role => role)
          @access_token = @user.authentication_token
          @alert = Factory(:alert, :user => @user)
          @alert2 = Factory(:alert, :user => @user)
        end
      end

      context '' do
        yield
      end


      should "create and update user alerts (json)" do
          assert_difference 'Alert.count', +1 do
            post "/users/me/alerts.json", {:access_token => @user.authentication_token}.merge(@fake_alert)
          end
          alerts = Alert.first(:order => 'id DESC')
          put "/users/me/alerts/#{alerts.id}.json", {
            :access_token => @user.authentication_token, 
            :schedule => "weekly",
            :delivery_method => "email",
            :query => {:test1 => "1111", :test2 => "2222"}
          }
          assert_response(200)
          assert_equal 'application/json', @response.content_type
          json = ActiveSupport::JSON.decode(response.body)
          assert_kind_of Hash, json
          assert_equal "ok", json['stat']
          assert_equal "weekly", json['alert']['schedule']
          assert_equal "1111", json['alert']['query']['test1']
      end

      should "create and destroy user alerts (json)" do
          assert_difference 'Alert.count', +1 do
            post "/users/me/alerts.json", {:access_token => @user.authentication_token}.merge(@fake_alert)
          end
          alerts = Alert.first(:order => 'id DESC')
          delete "/users/me/alerts/#{alerts.id}.json", {:access_token => @user.authentication_token}
          assert_response(200)
          assert_equal 'application/json', @response.content_type
          json = ActiveSupport::JSON.decode(response.body)
          assert_kind_of Hash, json
          assert_equal "ok", json['stat']
      end

      should "create and show query (json)" do
          assert_difference 'Alert.count', +1 do
            post "/users/me/alerts.json", {:access_token => @user.authentication_token}.merge(@fake_alert)
          end
          alerts = Alert.first(:order => 'id DESC')
          get "/alerts/#{alerts.search_code}.json"
          assert_response(200)
          assert_equal 'application/json', @response.content_type
          json = ActiveSupport::JSON.decode(response.body)
          assert_kind_of Hash, json
          assert_equal "ok", json['stat']
          assert_equal alerts.query, json['query']
      end

      should "list user alerts (json)" do
          get "/users/me/alerts.json", {:access_token => @user.authentication_token}
          assert_response(200)
          assert_equal 'application/json', @response.content_type
          json = ActiveSupport::JSON.decode(response.body)
          assert_kind_of Hash, json
          assert_equal "ok", json['stat']
          assert_operator json['alerts'].count, :>=, 1
      end

      should "not create a alert (json)" do
          post "/users/me/alerts.json", {:access_token => @user.authentication_token}
          assert_response(200)
          assert_equal 'application/json', @response.content_type
          json = ActiveSupport::JSON.decode(response.body)
          assert_kind_of Hash, json
          assert_equal "fail", json['stat']
          assert (json['err']['query'].include? 101)
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