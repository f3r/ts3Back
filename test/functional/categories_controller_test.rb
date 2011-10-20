require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase

  setup do
    @category = Factory(:category)
    @user = Factory(:user)
    User.confirm_by_token(@user.confirmation_token)    
  end
  
  # TODO: Check all tests

  # test "should get index (json)" do
  #   get :index, :format => :json
  #   assert_response :success
  #   assert_not_nil assigns(:categories)
  # end
  # 
  # test "should get index (xml)" do
  #   get :index, :format => :xml
  #   assert_response :success
  #   assert_not_nil assigns(:categories)
  # end
  # 
  # test "should not get index (html)" do
  #   get :index, :format => :html
  #   assert_response(406)
  #   assert_not_nil assigns(:categories)
  # end
  # 
  # test "should not create category (invalid token)" do
  #   post :create, name: Faker::Lorem.sentence(1), :format => :json, :access_token => "invalid_token"
  #   assert_response(401)
  # end
  # 
  # test "should create category (json)" do
  #   assert_difference('Category.count') do
  #     post :create, name: Faker::Lorem.sentence(1), :format => :json, :access_token => @user.authentication_token
  #   end
  #   assert_response :success
  # end
  # 
  # test "should create category (xml)" do
  #   assert_difference('Category.count') do
  #     post :create, name: Faker::Lorem.sentence(1), :format => :xml, :access_token => @user.authentication_token
  #   end
  #   assert_response :success
  # end
  # 
  # test "should not create category (html)" do
  #   assert_difference('Category.count') do
  #     post :create, name: Faker::Lorem.sentence(1), :format => :html, :access_token => @user.authentication_token
  #   end
  #   assert_response(406)
  # end
  # 
  # test "should show category (json)" do
  #   get :show, id: @category.to_param, :format => :json
  #   assert_response :success
  # end
  # 
  # test "should show category (xml)" do
  #   get :show, id: @category.to_param, :format => :xml
  #   assert_response :success
  # end
  # 
  # test "should not show category (html)" do
  #   get :show, id: @category.to_param, :format => :html
  #   assert_response(406)
  # end
  # 
  # test "should not update category (invalid token)" do
  #   put :update, id: @category.to_param, category: @category.attributes, :format => :json, :access_token => "invalid_token"
  #   assert_response(401)
  # end
  # 
  # test "should update category (json)" do
  #   put :update, id: @category.to_param, category: @category.attributes, :format => :json, :access_token => @user.authentication_token
  #   assert_response :success
  # end
  # 
  # test "should update category (xml)" do
  #   put :update, id: @category.to_param, category: @category.attributes, :format => :xml, :access_token => @user.authentication_token
  #   assert_response :success
  # end
  # 
  # test "should not update category (html)" do
  #   put :update, id: @category.to_param, category: @category.attributes, :format => :html, :access_token => @user.authentication_token
  #   assert_response(406)
  # end
  # 
  # test "should not destroy category (invalid token)" do
  #   delete :destroy, id: @category.to_param, :format => :json, :access_token => "invalid_token"
  #   assert_response(401)
  # end
  # 
  # test "should destroy category (json)" do
  #   assert_difference('Category.count', -1) do
  #     delete :destroy, id: @category.to_param, :format => :json, :access_token => @user.authentication_token
  #   end
  #   assert_response :success
  # end
  # 
  # test "should destroy category (xml)" do
  #   assert_difference('Category.count', -1) do
  #     delete :destroy, id: @category.to_param, :format => :xml, :access_token => @user.authentication_token
  #   end
  #   assert_response :success
  # end
  # 
  # test "should not destroy category (html)" do
  #   assert_difference('Category.count', -1) do
  #     delete :destroy, id: @category.to_param, :format => :html, :access_token => @user.authentication_token
  #   end
  #   assert_response(406)
  # end

end