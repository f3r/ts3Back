require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase

  setup do
    @category = Factory(:category)
    @user = Factory(:user)
    User.confirm_by_token(@user.confirmation_token)    
  end

  test "should get index" do
    get :index, :format => :json, :access_token => @user.authentication_token
    assert_response :success
    assert_not_nil assigns(:categories)
  end
  
  test "should create category" do
    assert_difference('Category.count') do
      post :create, name: "new category", :format => :json, :access_token => @user.authentication_token
    end
    assert_response :success
  end
  
  test "should show category" do
    get :show, id: @category.to_param, :format => :json, :access_token => @user.authentication_token
    assert_response :success
  end
  
  test "should update category" do
    put :update, id: @category.to_param, category: @category.attributes, :format => :json, :access_token => @user.authentication_token
    assert_response :success
  end
  
  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete :destroy, id: @category.to_param, :format => :json, :access_token => @user.authentication_token
    end
    assert_response :success
  end

end