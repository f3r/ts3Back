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
  
  test "reorder" do
    without_access_control do
      @place = Factory(:published_place)
    end
    assert_equal 3, @place.photos.count
    photo1, photo2, photo3 = @place.photos.all[0..2]
  
    ordered_ids = [photo3.id, photo1.id, photo2.id]
    @place.photos.set_positions(ordered_ids)
    
    photo_ids =  @place.photos.reload.collect(&:id)
    assert_equal ordered_ids, photo_ids
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
