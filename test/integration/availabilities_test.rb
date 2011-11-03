require 'test_helper'
class AvailabilitiesTest < ActionController::IntegrationTest

  setup do
    @country = Factory(:country)
    @state = Factory(:state)
    @city = Factory(:city)
    @user = Factory(:user)
    @user.confirm!
    @place_type = Factory(:place_type)
    @place = Factory(:place, :user => @user, :place_type => @place_type, :city => @city)
    
    @availability_occupied_new_info = { 
      :availability_type => 1, 
      :date_start        => "#{(Date.current + 2.year + 1.day).to_s}",
      :date_end          => "#{(Date.current + 2.year + 15.day).to_s}",
      :comment           => "new comment"
    }

    @availability_occupied_new_info_updated = { 
      :availability_type => 1, 
      :date_start        => "#{(Date.current + 2.year + 10.day).to_s}",
      :date_end          => "#{(Date.current + 2.year + 15.day).to_s}",
      :comment           => "different comment"
    }
    
    @availability_occupied_new_info_updated_invalid = {
      :availability_type => 1, 
      :date_start        => "#{(Date.current - 1.day).to_s}",
      :date_end          => "#{(Date.current - 2.day).to_s}"
    }
    
    @availability_new_price_new_info = { 
      :availability_type => 2,
      :date_start        => "#{(Date.current + 2.year + 1.day).to_s}",
      :date_end          => "#{(Date.current + 2.year + 15.day).to_s}",
      :price_per_night   => 150,
      :comment           => "new comment"
    }

    @availability_new_price_new_info_updated = { 
      :availability_type => 2,
      :date_start        => "#{(Date.current + 2.year + 1.day).to_s}",
      :date_end          => "#{(Date.current + 2.year + 15.day).to_s}",
      :price_per_night   => 150,
      :comment           => "new comment"
    }
        
    @availability_new_price_new_info_overlap = { 
      :availability_type => 2,
      :date_start        => "#{(Date.current + 2.year + 10.day).to_s}",
      :date_end          => "#{(Date.current + 2.year + 25.day).to_s}"
    }
  end

  should "create place availability occupied and update it (json)" do
    assert_difference 'Availability.count', +1 do
      post "/places/#{@place.id}/availabilities.json", 
        {:access_token => @user.authentication_token}.merge(@availability_occupied_new_info)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @availability_occupied_new_info[:availability_type],  json['availability']['availability_type']
    assert_equal @availability_occupied_new_info[:date_start],         json['availability']['date_start']
    assert_equal @availability_occupied_new_info[:date_end],           json['availability']['date_end']
    assert_equal @availability_occupied_new_info[:comment],            json['availability']['comment']
    
    availability = Availability.first(:order => 'id DESC')
    put "/places/#{@place.id}/availabilities/#{availability.id}.json", 
      {:access_token => @user.authentication_token}.merge(@availability_occupied_new_info_updated)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @availability_occupied_new_info_updated[:availability_type],  json['availability']['availability_type']
    assert_equal @availability_occupied_new_info_updated[:date_start],         json['availability']['date_start']
    assert_equal @availability_occupied_new_info_updated[:date_end],           json['availability']['date_end']
    assert_equal @availability_occupied_new_info_updated[:comment],            json['availability']['comment']    
  end
  
  should "create place availability updating new price and update it (json)" do
    assert_difference 'Availability.count', +1 do
      post "/places/#{@place.id}/availabilities.json", 
        {:access_token => @user.authentication_token}.merge(@availability_new_price_new_info)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @availability_new_price_new_info[:availability_type],  json['availability']['availability_type']
    assert_equal @availability_new_price_new_info[:date_start],         json['availability']['date_start']
    assert_equal @availability_new_price_new_info[:date_end],           json['availability']['date_end']
    assert_equal @availability_new_price_new_info[:comment],            json['availability']['comment']
    
    availability = Availability.first(:order => 'id DESC')
    put "/places/#{@place.id}/availabilities/#{availability.id}.json", 
      {:access_token => @user.authentication_token}.merge(@availability_new_price_new_info_updated)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @availability_new_price_new_info_updated[:availability_type],  json['availability']['availability_type']
    assert_equal @availability_new_price_new_info_updated[:date_start],         json['availability']['date_start']
    assert_equal @availability_new_price_new_info_updated[:date_end],           json['availability']['date_end']
    assert_equal @availability_new_price_new_info_updated[:comment],            json['availability']['comment']    
  end
  
  should "not create place availability if begin/end overlaps a previous one (json)" do
    post "/places/#{@place.id}/availabilities.json", 
      {:access_token => @user.authentication_token}.merge(@availability_new_price_new_info)
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal @availability_new_price_new_info[:date_start], json['availability']['date_start']
    assert_equal @availability_new_price_new_info[:date_end],   json['availability']['date_end']
  
    post "/places/#{@place.id}/availabilities.json", 
      {:access_token => @user.authentication_token}.merge(@availability_new_price_new_info_overlap)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [121],  json['err']['message']
  end
  
  should "create place availability occupied and not update wrong dates (json)" do
    post "/places/#{@place.id}/availabilities.json", 
        {:access_token => @user.authentication_token}.merge(@availability_occupied_new_info)
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal @availability_occupied_new_info[:date_start],         json['availability']['date_start']
    assert_equal @availability_occupied_new_info[:date_end],           json['availability']['date_end']
    
    availability = Availability.first(:order => 'id DESC')
    put "/places/#{@place.id}/availabilities/#{availability.id}.json", 
      {:access_token => @user.authentication_token}.merge(@availability_occupied_new_info_updated_invalid)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [119],  json['err']['date_start']
    assert_equal [120],  json['err']['date_end']
  end
  
  should "delete place availability (json)" do
    post "/places/#{@place.id}/availabilities.json", 
        {:access_token => @user.authentication_token}.merge(@availability_occupied_new_info)
    assert_response(200)
        
    availability = Availability.first(:order => 'id DESC')
  
    assert_difference 'Availability.count', -1 do
      delete "/places/#{@place.id}/availabilities/#{availability.id}.json", 
        {:access_token => @user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "not create place availability if place doesn't exist (json)" do
    post "/places/8287278/availabilities.json", 
        {:access_token => @user.authentication_token}.merge(@availability_occupied_new_info)    
    assert_response(404)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [106],  json['err']['record']
  end
end