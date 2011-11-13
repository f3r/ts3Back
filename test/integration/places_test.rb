require 'test_helper'
require 'money'
require 'money/bank/google_currency'
Money.default_bank = Money::Bank::GoogleCurrency.new

class PlacesTest < ActionController::IntegrationTest

  setup do
    @city = Factory(:city)
    @admin_user = Factory(:user, :role => "admin")
    @admin_user.confirm!
    Authorization.current_user = @admin_user
    @place_type = Factory(:place_type)
    @place = Factory(:place, :user => @admin_user, :place_type => @place_type, :city => @city)
    @availability = Factory(:availability, :place => @place )
    @photos = [{:url => "http://example.com/yoda.jpg",:description => "Yoda"}, {:url => "http://example.com/darthvader.jpg",:description => "Darth Vader"}].to_json
    @place_new_info = { 
      :title => "Test title", 
      :amenities_kitchen => true, 
      :amenities_tennis => true, 
      :photos => @photos,
      :currency => "JPY",
      :price_per_night => "8000",
      :price_per_week => "128000",
      :price_per_month => "400000"
    }
    @new_place = { :title => "test title", :place_type_id => @place_type.id, :num_bedrooms => 3, :max_guests => 5, :city_id => @city.id }
  end

  should "get place information as admin (json)" do
    get "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @place.id, json['place']['id']
  end

  should "get place information as admin (xml)" do
    get "/places/#{@place.id}.xml", {:access_token => @admin_user.authentication_token}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag "place", :child => { :tag => "id", :content => @place.id.to_s }
  end
  
  should "delete place (json)" do
    assert_difference 'Place.count', -1 do
      delete "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
    
  should "delete place (xml)" do
    assert_difference 'Place.count', -1 do
      delete "/places/#{@place.id}.xml", {:access_token => @admin_user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end
  
  should "update place" do
    put "/places/#{@place.id}.json", @place_new_info.merge({:access_token => @admin_user.authentication_token})
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_equal @place_new_info[:title], json['place']['title']
    assert_equal true, json['place']['amenities_kitchen']
    assert_equal true, json['place']['amenities_tennis']
    assert_not_nil json['place']['photos']
    assert_equal @place_new_info[:price_per_night].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['price_per_night_usd']
    assert_equal @place_new_info[:price_per_week].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['price_per_week_usd']
    assert_equal @place_new_info[:price_per_month].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['price_per_month_usd']
  end  

  should "update place, publish it and unpublish it" do
    put "/places/#{@place.id}.json", @place_new_info.merge({:access_token => @admin_user.authentication_token})
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    get "/places/#{@place.id}/publish.json", {:access_token => @admin_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_equal true, json['place']['published']
    get "/places/#{@place.id}/unpublish.json", {:access_token => @admin_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_equal false, json['place']['published']
  end
  
  should "not publish place with incomplete information" do
    get "/places/#{@place.id}/publish.json", {:access_token => @admin_user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_not_nil false, json['err']['publish']
  end

  should "create a place and update it's information (json)" do
    assert_difference 'Place.count', +1 do
      post '/places.json', @new_place.merge({:access_token => @admin_user.authentication_token})
    end
    place = Place.first(:order => 'id DESC')
    put "/places/#{place.id}.json", @place_new_info.merge({:access_token => @admin_user.authentication_token})
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @place_new_info[:title], json['place']['title']
    assert_equal true, json['place']['amenities_kitchen']
    assert_equal true, json['place']['amenities_tennis']
    assert_not_nil json['place']['photos']
    assert_equal @place_new_info[:price_per_night].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['price_per_night_usd']
    assert_equal @place_new_info[:price_per_week].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['price_per_week_usd']
    assert_equal @place_new_info[:price_per_month].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['price_per_month_usd']
  end

  should "create a place and update it's information (xml)" do
    assert_difference 'Place.count', +1 do
      post '/places.xml', { :title => "test title2", :place_type_id => @place_type.id, :num_bedrooms => 5, :max_guests => 10, :city_id => @city.id, :access_token => @admin_user.authentication_token }
    end
    place = Place.first(:order => 'id DESC')
    put "/places/#{place.id}.xml", @place_new_info.merge({:access_token => @admin_user.authentication_token})
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag "place", :child => { :tag => "title", :content => @place_new_info[:title] }
    assert_tag "place", :child => { :tag => "amenities_kitchen", :content => "true" }
    assert_tag "place", :child => { :tag => "amenities_tennis", :content => "true" }
    assert_not_nil "place", :child => { :tag => "photos" }
    assert_tag "place", :child => { :tag => "price_per_night_usd", :content => @place_new_info[:price_per_night].to_money(@place_new_info[:currency]).exchange_to(:USD).cents.to_s }
    assert_tag "place", :child => { :tag => "price_per_week_usd", :content => @place_new_info[:price_per_week].to_money(@place_new_info[:currency]).exchange_to(:USD).cents.to_s }
    assert_tag "place", :child => { :tag => "price_per_month_usd", :content => @place_new_info[:price_per_month].to_money(@place_new_info[:currency]).exchange_to(:USD).cents.to_s }
  end

  should "update place dimessions in meters (json)" do
    put "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token, :size => 100, :size_unit => "meters"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "meters", json['place']['size_unit']
    assert_equal 100, json['place']['size_sqm']
    assert_equal 100 * 10.7639104, json['place']['size_sqf']
  end

  should "update place dimessions in feet (json)" do
    put "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token, :size => 1000, :size_unit => "feet"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "feet", json['place']['size_unit']
    assert_equal 1000, json['place']['size_sqf']
    assert_equal 1000 * 0.09290304, json['place']['size_sqm']
  end

  should "not update place dimessions with invalid size_unit (json)" do
    put "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token, :size => 1000, :size_unit => "zapatos"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['size_unit'].include? 129)
  end

  should "update place with valid US zip code (json)" do
    put "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token, :zip => "33122-1111"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not update place with invalid zip code (json)" do
    put "/places/#{@place.id}.json", {:access_token => @admin_user.authentication_token, :zip => "3333333333"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "get a users unpublished places" do
    get "/users/#{@admin_user.id}/places.json", {:access_token => @admin_user.authentication_token, :published => 0}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @place.id, json['places'][0]['id']
    assert_equal @place.title, json['places'][0]['title']
  end
  
  should "get no search results" do
    get "/places/search.json", { :q => { :size_sqm_gt => 10000 }, :status => "published" }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert (json['err']['places'].include? 115)
  end

  should "get no results with empty query" do
    get "/places/search.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert (json['err']['query'].include? 101)
  end

  should "get search results" do
    get "/places/search.json", {:q => {:num_bedrooms_eq => @place.num_bedrooms}, :status => "all"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['places']
    assert_operator json['results'], :>, 0
  end
  
end