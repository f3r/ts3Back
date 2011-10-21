require 'test_helper'
class CategoriesTest < ActionController::IntegrationTest

  setup do
    @category = Factory(:category)
    @user = Factory(:user)
    @user.confirm!
  end

  should "create a category (xml)" do
    assert_difference('Category.count') do
      post '/categories.xml', { :name => "testing", :access_token => @user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'category', :child => { :tag => "name", :content => "testing" }
  end

  should "create a category (json)" do
    assert_difference('Category.count') do
      post '/categories.json', { :name => "testing", :access_token => @user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "testing", json['category']['name']
  end

  should "not create category, name taken (xml)" do
    post '/categories.xml', { :name => @category.name, :access_token => @user.authentication_token }
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "name", :content => "100" }
  end

  should "create a category with parent (xml)" do
    assert_difference('Category.count') do
      post '/categories.xml', { :name => "child category", :parent_id => @category.id, :access_token => @user.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'category', :child => { :tag => "name", :content => "child category" }
    assert_tag 'category', :child => { :tag => "ancestry", :content => @category.id.to_s }
  end

  should "show a category (xml)" do
    get "/categories/#{@category.id}.xml"
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'category', :child => { :tag => "name", :content => @category.name }
  end

  should "show a category (json)" do
    get "/categories/#{@category.id}.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @category.name, json['category']['name']
  end

  should "not show a category, not found (xml)" do
    get "/categories/100000000.xml"
    assert_response(404)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "record", :content => "106" }
  end

  should "update a category (json)" do
    put "/categories/#{@category.id}.json", { :name => "wooo", :access_token => @user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "wooo", json['category']['name']
  end

  should "destroy a category (json)" do
    delete "/categories/#{@category.id}.json", { :access_token => @user.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
end