require 'test_helper'
class CitiesTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @city = Factory(:city)
      @agent_user = Factory(:user, :role => "agent")
      Authorization.current_user = @agent_user

      10.times do
        place = Factory(:published_place, :user => @agent_user, :city => @city)
      end

    end
  end

  should "show city price range (json)" do
    get "/geo/cities/#{@city.id}/price_range.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_operator json['min_price'], :>=, 1000
    assert_operator json['max_price'], :<=, 10000
  end

  should "show city price range with SGD currency (json)" do
    get "/geo/cities/#{@city.id}/price_range.json", {:currency => "SGD" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_operator json['min_price'], :>=, 1000
    assert_operator json['max_price'], :<=, 13000
  end
  
  should "show city price range with JPY currency (json)" do
    get "/geo/cities/#{@city.id}/price_range.json", {:currency => "JPY" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_operator json['min_price'], :>=, 70000
    assert_operator json['max_price'], :<=, 800000
  end

end