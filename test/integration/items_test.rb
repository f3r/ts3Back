require 'test_helper'
class ItemsTest < ActionController::IntegrationTest

  should "get images list (json)" do
    get '/items/image_search.json', {:query => "harry potter goblet of fire"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['images']
  end

  should "get images list (xml)" do
    get '/items/image_search.xml', {:query => "harry potter goblet of fire"}
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'images', :child => { :tag => "image" }
  end

end