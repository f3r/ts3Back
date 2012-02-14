require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  test "json serialization format" do
     @photo = Factory(:photo)
     puts @photo.to_json
     nil.error
  end
end
