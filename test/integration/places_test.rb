require 'test_helper'
require 'money'
require 'money/bank/google_currency'
Money.default_bank = Money::Bank::GoogleCurrency.new

class PlacesTest < ActionController::IntegrationTest

  setup do
    @country = Factory(:country)
    @state = Factory(:state)
    @city = Factory(:city)
    @user = Factory(:user)
    @user.confirm!
    @place_type = Factory(:place_type)
    @place = Factory(:place, :user => @user, :place_type => @place_type, :city => @city)
    @photos = [{:url => "http://example.com/yoda.jpg",:description => "Yoda"}, {:url => "http://example.com/darthvader.jpg",:description => "Darth Vader"}]
    @place_new_info = { 
      :title => "Test title", 
      :amenities => {:tennis => true, :kitchen => true}, 
      :photos => @photos.to_json,
      :currency => "JPY",
      :price_per_night => "8000",
      :price_per_week => "128000",
      :price_per_month => "400000"
    }
    @new_place = { :title => "test title", :place_type_id => @place_type.id, :num_bedrooms => 3, :max_guests => 5, :city_id => @city.id }
  end

  should "get place information (json)" do
    get "/places/#{@place.id}.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @place.id, json['place']['id']
  end

  should "get place information (xml)" do
    get "/places/#{@place.id}.xml"
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag "place", :child => { :tag => "id", :content => @place.id.to_s }
  end
  
  should "delete place (json)" do
    assert_difference 'Place.count', -1 do
      delete "/places/#{@place.id}.json", {:access_token => @user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
    
  should "delete place (xml)" do
    assert_difference 'Place.count', -1 do
      delete "/places/#{@place.id}.xml", {:access_token => @user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
  end
  
  should "update place" do
    put "/places/#{@place.id}.json", @place_new_info.merge({:access_token => @user.authentication_token})
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_equal @place_new_info[:title], json['place']['details']['title']
    assert_equal true, json['place']['amenities']['kitchen']
    assert_equal true, json['place']['amenities']['tennis']
    assert_not_nil json['place']['photos']
    assert_equal @place_new_info[:price_per_night].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['pricing']['price_per_night_usd']
    assert_equal @place_new_info[:price_per_week].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['pricing']['price_per_week_usd']
    assert_equal @place_new_info[:price_per_month].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['pricing']['price_per_month_usd']
  end  

  should "update place, publish it and unpublish it" do
    put "/places/#{@place.id}.json", @place_new_info.merge({:access_token => @user.authentication_token})
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    get "/places/#{@place.id}/publish.json", {:access_token => @user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_equal true, json['place']['published']
    get "/places/#{@place.id}/unpublish.json", {:access_token => @user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_equal false, json['place']['published']
  end
  
  should "not publish place with incomplete information" do
    get "/places/#{@place.id}/publish.json", {:access_token => @user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']    
    assert_not_nil false, json['err']['publish']
  end

  should "create a place and update it's information (json)" do
    assert_difference 'Place.count', +1 do
      post '/places.json', @new_place.merge({:access_token => @user.authentication_token})
    end
    place = Place.first(:order => 'id DESC')
    put "/places/#{place.id}.json", @place_new_info.merge({:access_token => @user.authentication_token})
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @place_new_info[:title], json['place']['details']['title']
    assert_equal true, json['place']['amenities']['kitchen']
    assert_equal true, json['place']['amenities']['tennis']
    assert_not_nil json['place']['photos']
    assert_equal @place_new_info[:price_per_night].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['pricing']['price_per_night_usd']
    assert_equal @place_new_info[:price_per_week].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['pricing']['price_per_week_usd']
    assert_equal @place_new_info[:price_per_month].to_money(@place_new_info[:currency]).exchange_to(:USD).cents, json['place']['pricing']['price_per_month_usd']
  end

  # TODO: Must fix state error
  should "create a place and update it's information (xml)" do
    assert_difference 'Place.count', +1 do
      post '/places.xml', { :title => "test title2", :place_type_id => @place_type.id, :num_bedrooms => 5, :max_guests => 10, :city_id => @city.id, :access_token => @user.authentication_token }
    end
    place = Place.first(:order => 'id DESC')
    put "/places/#{place.id}.xml", @place_new_info.merge({:access_token => @user.authentication_token})
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag "place", :child => { :tag => "details", :child => { :tag => "title", :content => @place_new_info[:title] } }
    assert_tag "place", :child => { :tag => "amenities", :child => { :tag => "kitchen", :content => "true" } }
    assert_tag "place", :child => { :tag => "amenities", :child => { :tag => "tennis", :content => "true" } }
    assert_not_nil "place", :child => { :tag => "photos" }
    assert_tag "place", :child => { :tag => "pricing", :child => { :tag => "price_per_night_usd", :content => @place_new_info[:price_per_night].to_money(@place_new_info[:currency]).exchange_to(:USD).cents.to_s } }
    assert_tag "place", :child => { :tag => "pricing", :child => { :tag => "price_per_week_usd", :content => @place_new_info[:price_per_week].to_money(@place_new_info[:currency]).exchange_to(:USD).cents.to_s } }
    assert_tag "place", :child => { :tag => "pricing", :child => { :tag => "price_per_month_usd", :content => @place_new_info[:price_per_month].to_money(@place_new_info[:currency]).exchange_to(:USD).cents.to_s } }
  end

  should "get a users unpublished places" do
    get "/users/#{@user.id}/places.json", {:access_token => @user.authentication_token, :published => 0}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @place.id, json['places'][0]['id']
    assert_equal @place.title, json['places'][0]['details']['title']
  end
  
end