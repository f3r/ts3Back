require 'test_helper'
class TransactionsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin = Factory(:user, :role => "admin")
      @admin.confirm!
      Authorization.current_user = @admin
      @published_place = Factory( :place, 
                                  :user => @admin, 
                                  :place_type => Factory(:place_type), 
                                  :city => Factory(:city),
                                  :amenities_kitchen => true, 
                                  :amenities_tennis => true, 
                                  :photos => [{:url => "http://example.com/yoda.jpg",:description => "Yoda"}, {:url => "http://example.com/darthvader.jpg",:description => "Darth Vader"}].to_json,
                                  :currency => "JPY",
                                  :price_per_night => "8000",
                                  :price_per_week => "51000",
                                  :price_per_month => "245000"
                                )
      @published_place_availability = Factory(:availability, :place => @published_place, :price_per_night => 9000, :comment => "test" )
      @published_place_availability2 = Factory(:availability, 
        :place => @published_place, 
        :comment => "restoration", 
        :availability_type => 1, 
        :date_start => (Date.today + 1.month).to_s, 
        :date_end => (Date.today + 2.months).to_s)
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

      should "check place availability, available (json)" do
        get "/places/#{@published_place.id}/check_availability.json", {
          :access_token => @access_token,
          :check_in => (Date.today + 350.days).to_s,
          :check_out => (Date.today + 360.days).to_s
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        assert_equal 10, json['total_days']
        assert_not_nil json['dates']
      end

      should "check place availability with custom currency, available (json)" do
        get "/places/#{@published_place.id}/check_availability.json", {
          :access_token => @access_token,
          :check_in => (Date.today + 350.days).to_s,
          :check_out => (Date.today + 360.days).to_s,
          :currency => "USD"
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "ok", json['stat']
        assert_equal 10, json['total_days']
        assert_equal "USD", json['currency']
        # something between 100 and 140 (exchange rate changes!)
        assert_operator json['avg_price_per_night'], :>=, 100
        assert_operator json['avg_price_per_night'], :<=, 140
        assert_not_nil json['dates']
      end

      should "not check place availability, invalid check_in (json)" do
        get "/places/#{@published_place.id}/check_availability.json", {
          :access_token => @access_token,
          :check_in => (Date.today - 10.days).to_s,
          :check_out => (Date.today + 11.days).to_s
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "fail", json['stat']
        assert (json['err']['check_in'].include? 119)
      end

      should "not check place availability, invalid check_out (json)" do
        get "/places/#{@published_place.id}/check_availability.json", {
          :access_token => @access_token,
          :check_in => (Date.today + 10.days).to_s,
          :check_out => (Date.today).to_s
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "fail", json['stat']
        assert (json['err']['check_out'].include? 120)
      end

      should "not check place availability, empty check_in and check_out (json)" do
        get "/places/#{@published_place.id}/check_availability.json", {
          :access_token => @access_token
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "fail", json['stat']
        assert (json['err']['check_in'].include? 113)
        assert (json['err']['check_out'].include? 113)
      end

      should "check place availability, unavailable (json)" do
        get "/places/#{@published_place.id}/check_availability.json", {
          :access_token => @access_token,
          :check_in => (Date.today + 30.days).to_s,
          :check_out => (Date.today + 40.days).to_s
        }
        assert_response(200)
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal "fail", json['stat']
        assert_not_nil json['dates']
        assert (json['err']['place'].include? 136)
      end

    end
  end

  logged_in_as "user" do
  end
  logged_in_as "admin" do
  end
  logged_in_as "agent" do
  end
  
  # TODO: users transactions, places transactions

end