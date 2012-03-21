require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  setup do
    without_access_control do
      @user = Factory(:user)
    end
  end

  test "something" do
    
  end
end
