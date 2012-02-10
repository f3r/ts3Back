require 'test_helper'

class PlaceSearchTest < ActiveSupport::TestCase
  setup do
    without_access_control do
      @user = Factory(:user)
    end
  end
  
  test "empty search" do
    ps = PlaceSearch.new(@user, {})
    assert ps.results
  end
  
  test "country conditions" do
    ps = PlaceSearch.new(@user, :q => {:country_code_eq => 'SG'})
    conditions = ps.send(:prepare_conditions)
    assert_equal({:country_code_eq => 'SG'}, conditions)
  end
end
