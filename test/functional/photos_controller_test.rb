require 'test_helper'

class PhotosControllerTest < ActionController::TestCase
  setup do
    @request.accept = 'application/json'
    without_access_control do
      @user = Factory(:user, :role => 'agent')
      @place = Factory(:valid_place, :user => @user)
    end
    Photo.attachment_definitions[:photo][:path] = "public/system/places/:id/photos/:uniq_id/:style.:extension"
  end
  
  test "uploads a photo" do
    assert_difference('Photo.count', 1) do
      post :create, { :access_token => @user.authentication_token, :place_id => @place.id,
        :photo => fixture_file_upload('test_image.jpg', 'image/jpg')
      }
    end
    
    assert_ok
  end
  
  test "removes a photo" do
    @photo = Factory(:photo)

    assert_difference('Photo.count', -1) do
      post :destroy, { :access_token => @user.authentication_token, :place_id => @place.id,
        :id => @photo.id 
      }
    end
    
    assert_ok
  end
  
  test "list photos" do
    3.times.each { Factory(:photo, :place => @place) }
    assert_equal 3, @place.photos.count
    
    get :index, { :access_token => @user.authentication_token, :place_id => @place.id }
    json = ActiveSupport::JSON.decode(response.body)
    
    assert_equal 3, json['photos'].size
  end

  def assert_ok
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
end
