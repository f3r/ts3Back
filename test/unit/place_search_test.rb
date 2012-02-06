require 'test_helper'

class PlaceSearchTest < ActiveSupport::TestCase
  setup do
    @user = Factory(:user)
  end
  
  test "empty search" do
    ps = PlaceSearch.new(@user, {})
    assert ps.results
  end
  
  test "country conditions" do
    ps = PlaceSearch.new(@user, {:country_code_eq => 'SG'})
    conditions = ps.send(:prepare_conditions)
    assert_equal conditions, {:country_code_eq => 'SG'}
  end
end
