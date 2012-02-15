require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  setup do
    without_access_control do
      @photo = Factory(:photo)
    end
  end
  
  test "json serialization format" do
    json = @photo.to_json
    h = ActiveSupport::JSON.decode(json)
    assert_equal @photo.name, h["photo"]["name"]
    assert_equal @photo.photo.url, h["photo"]["original"]
  end
  
  # test "place photos serialization" do
  #   places = [@photo.place]
  #   json = places.to_json
  #   h = ActiveSupport::JSON.decode(json)
  #   assert_equal 1, h[0]['photos'].size
  #   photo = h[0]['photos'][0]
  #   assert_equal @photo.photo.url, photo['photo']['original']
  # end
end
