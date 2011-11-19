require 'test_helper'
class PlaceTypesTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @place_type = Factory(:place_type)
      @admin = Factory(:user, :role => "admin")
      @admin.confirm!
      @agent = Factory(:user, :role => "agent")
      @agent.confirm!
      Authorization.current_user = @admin
    end
  end

  should "create a place_type as admin (xml)" do
    assert_difference('PlaceType.count') do
      post '/place_types.xml', { :name => "testing", :access_token => @admin.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "ok" }
    assert_tag 'place_type', :child => { :tag => "name", :content => "testing" }
  end

  should "create a place_type as admin (json)" do
    assert_difference('PlaceType.count') do
      post '/place_types.json', { :name => "testing", :access_token => @admin.authentication_token }
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "testing", json['place_type']['name']
  end

  should "not create place_type, name taken as admin (xml)" do
    post '/place_types.xml', { :name => @place_type.name, :access_token => @admin.authentication_token }
    assert_response(200)
    assert_equal 'application/xml', @response.content_type
    assert_tag 'rsp', :child => { :tag => "stat", :content => "fail" }
    assert_tag 'err', :child => { :tag => "name", :content => "100" }
  end

  should "update a place_type as admin (json)" do
    put "/place_types/#{@place_type.id}.json", { :name => "wooo", :access_token => @admin.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "wooo", json['place_type']['name']
  end

  should "destroy a place_type as admin (json)" do
    delete "/place_types/#{@place_type.id}.json", { :access_token => @admin.authentication_token }
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  should "not create a place_type as agent (json)" do
    post '/place_types.json', { :name => "testing", :access_token => @agent.authentication_token }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

  should "not update a place_type as agent (json)" do
    put "/place_types/#{@place_type.id}.json", { :name => "wooo", :access_token => @agent.authentication_token }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

  should "not delete a place_type as agent (json)" do
    delete "/place_types/#{@place_type.id}.json", { :access_token => @agent.authentication_token }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

  should "not create a place_type as guest (json)" do
    post '/place_types.json', { :name => "testing" }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

  should "not update a place_type as guest (json)" do
    put "/place_types/#{@place_type.id}.json", { :name => "wooo" }
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

  should "not delete a place_type as guest (json)" do
    delete "/place_types/#{@place_type.id}.json"
    assert_response(403)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert (json['err']['authorization'].include? 133)
  end

end