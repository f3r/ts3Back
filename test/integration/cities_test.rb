require 'test_helper'
class CitiesTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @city = Factory(:city)
      @agent_user = Factory(:user, :role => "agent")
      @agent_user.confirm!
      Authorization.current_user = @agent_user

      10.times do
        place = Place.create!(
          :user_id => @agent_user.id,
          :description => Faker::Lorem.sentence(20),
          :title => Faker::Lorem.sentence(2),
          :photos => [{:url => "http://example.com/luke.jpg",:description => "Luke"}, {:url => "http://example.com/yoda.jpg",:description => "Yoda"}, {:url => "http://example.com/darthvader.jpg",:description => "Darth Vader"}].to_json,
          :address_1 => Faker::Lorem.sentence(2),
          :zip => '123456',
          :place_type_id => (1..7).to_a.sample,
          :num_bedrooms => (1..6).to_a.sample,
          :max_guests => (1..10).to_a.sample,
          :city_id => @city.id,
          :price_per_month => (1000..10000).to_a.sample,
          :currency => "USD",
          :size_unit => ["meters","feet"].to_a.sample,
          :size => (50..200).to_a.sample,
          :amenities_tv => true
        )
        place.publish!
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