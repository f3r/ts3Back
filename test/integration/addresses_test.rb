require 'test_helper'
class AddressesTest < ActionController::IntegrationTest

  setup do
    @user = Factory(:user)
    @user.confirm!
    @address = Factory(:address, :user => @user)
    @fake_address = { 
      :street => Faker::Address.street_address,
      :city => Faker::Address.city,
      :country => Faker::Address.country,
      :zip => Faker::Address.zip,
      :user_id => @user.id
    }
  end

  should "create user addresses (json)" do
    assert_difference 'Address.count', +1 do
      post '/users/addresses.json', {:access_token => @user.authentication_token}.merge(@fake_address)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @fake_address[:street], json['address']['street']
  end

  should "create and update user addresses (json)" do
      assert_difference 'Address.count', +1 do
        post '/users/addresses.json', {:access_token => @user.authentication_token}.merge(@fake_address)
      end
      address = Address.first(:order => 'id DESC')
      put "/users/addresses/#{address.id}.json", {
        :access_token => @user.authentication_token, 
        :street => "testing",
        :city => "chame",
        :country => "us",
        :zip => "1100"}
      assert_response(200)
      assert_equal 'application/json', @response.content_type
      json = ActiveSupport::JSON.decode(response.body)
      assert_kind_of Hash, json
      assert_equal "ok", json['stat']
      assert_equal "testing", json['address']['street']
  end

  should "list user addresses (json)" do
    get '/users/addresses.json', {:access_token => @user.authentication_token}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "create and delete user addresses (json)" do
    assert_difference 'Address.count', +1 do
      post '/users/addresses.json', {:access_token => @user.authentication_token}.merge(@fake_address)
    end
    address = Address.first(:order => 'id DESC')
    assert_difference 'Address.count', -1 do
      delete "/users/addresses/#{address.id}.json", {:access_token => @user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

end