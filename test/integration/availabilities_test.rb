require 'test_helper'
class AvailabilitiesTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @city = Factory(:city)
      @admin_user = Factory(:user, :role => "admin")
      @admin_user.confirm!
      Authorization.current_user = @admin_user
      @agent_user = Factory(:user, :role => "agent")
      @agent_user.confirm!
      @place_type = Factory(:place_type)
      @place = Factory(:place, :user => @admin_user, :place_type => @place_type, :city => @city)
      @availability = Factory(:availability, 
        :place => @place,
        :availability_type => 2,
        :price_per_night   => 8000,
        :date_start        => (Date.current + 3.year).to_s,
        :date_end          => (Date.current + 3.year + 2.days).to_s
      )
      @agent_place = Factory(:place, :user => @agent_user, :place_type => @place_type, :city => @city)

      @photos = [{:url => "http://example.com/luke.jpg",:description => "Luke"}, {:url => "http://example.com/yoda.jpg",:description => "Yoda"}, {:url => "http://example.com/darthvader.jpg",:description => "Darth Vader"}].to_json
      @published_place = Factory( :place, 
                                  :user => @agent_user, 
                                  :place_type => @place_type, 
                                  :city => @city,
                                  :amenities_kitchen => true, 
                                  :amenities_tennis => true, 
                                  :photos => @photos,
                                  :currency => "JPY",
                                  :price_per_month => "400000",
                                  :size_unit => 'meters',
                                  :size => 100
                                )
      @published_place_availability = Factory(:availability, 
        :place => @published_place,
        :availability_type => 2,
        :price_per_night   => 9000,
        :date_start        => (Date.current + 3.year).to_s,
        :date_end          => (Date.current + 3.year + 2.days).to_s
      )
      @published_place.publish!

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
    
      @availability_occupied_new_info_overlap = { 
        :availability_type => 1, 
        :date_start        => "#{(Date.current + 2.year + 10.day).to_s}",
        :date_end          => "#{(Date.current + 2.year + 25.day).to_s}",
        :comment           => "new other comment"
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
  end
  
  should "create place availability occupied and update it as admin (json)" do
    assert_difference 'Availability.count', +1 do
      post "/places/#{@place.id}/availabilities.json", 
        {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info)
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
      {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info_updated)
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
  
  should "create place availability occupied and update it as agent (json)" do
    assert_difference 'Availability.count', +1 do
      post "/places/#{@agent_place.id}/availabilities.json", 
        {:access_token => @agent_user.authentication_token}.merge(@availability_occupied_new_info)
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
    put "/places/#{@agent_place.id}/availabilities/#{availability.id}.json", 
      {:access_token => @agent_user.authentication_token}.merge(@availability_occupied_new_info_updated)
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
        {:access_token => @admin_user.authentication_token}.merge(@availability_new_price_new_info)
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
      {:access_token => @admin_user.authentication_token}.merge(@availability_new_price_new_info_updated)
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
      {:access_token => @admin_user.authentication_token}.merge(@availability_new_price_new_info)
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal @availability_new_price_new_info[:date_start], json['availability']['date_start']
    assert_equal @availability_new_price_new_info[:date_end],   json['availability']['date_end']
  
    post "/places/#{@place.id}/availabilities.json", 
      {:access_token => @admin_user.authentication_token}.merge(@availability_new_price_new_info_overlap)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [121],  json['err']['message']
  end
  
  should "create place availability if begin/end overlaps a previous one for occupied type (json)" do
    post "/places/#{@place.id}/availabilities.json", 
      {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @availability_occupied_new_info[:date_start], json['availability']['date_start']
    assert_equal @availability_occupied_new_info[:date_end],   json['availability']['date_end']
    post "/places/#{@place.id}/availabilities.json", 
      {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info_overlap)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "create place availability occupied and not update wrong dates (json)" do
    post "/places/#{@place.id}/availabilities.json", 
        {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info)
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal @availability_occupied_new_info[:date_start],         json['availability']['date_start']
    assert_equal @availability_occupied_new_info[:date_end],           json['availability']['date_end']
    
    availability = Availability.first(:order => 'id DESC')
    put "/places/#{@place.id}/availabilities/#{availability.id}.json", 
      {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info_updated_invalid)
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [119],  json['err']['date_start']
    assert_equal [120],  json['err']['date_end']
  end
  
  should "delete place availability as admin (json)" do
    assert_difference 'Availability.count', +1 do
      post "/places/#{@agent_place.id}/availabilities.json", 
          {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info)
    end
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_difference 'Availability.count', -1 do
      delete "/places/#{@agent_place.id}/availabilities/#{json['availability']['id']}.json", 
        {:access_token => @admin_user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "delete place availability as agent (json)" do
    assert_difference 'Availability.count', +1 do
      post "/places/#{@agent_place.id}/availabilities.json", 
          {:access_token => @agent_user.authentication_token}.merge(@availability_occupied_new_info)
    end
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_difference 'Availability.count', -1 do
      delete "/places/#{@agent_place.id}/availabilities/#{json['availability']['id']}.json", 
        {:access_token => @agent_user.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "not delete admin place availability as agent (json)" do
    delete "/places/#{@place.id}/availabilities.json", {:access_token => @agent_user.authentication_token}
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
  end
  
  should "not delete place availability as guest (json)" do
    delete "/places/#{@place.id}/availabilities.json"
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
  end
  
  should "not create place availability if place doesn't exist (json)" do
    post "/places/8287278/availabilities.json", 
        {:access_token => @admin_user.authentication_token}.merge(@availability_occupied_new_info)    
    assert_response(404)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    assert_equal [106],  json['err']['record']
  end
  
  should "list published place availabilities as guest" do
    get "/places/#{@published_place.id}/availabilities.json"
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end
  
  should "list published place availabilities with a different currency as guest" do
    get "/places/#{@published_place.id}/availabilities.json", {:currency => "USD"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    # something between 100 and 140 (exchange rate changes!)
    assert_operator json['availabilities'][0]['price_per_night'], :>=, 100
    assert_operator json['availabilities'][0]['price_per_night'], :<=, 140
  end
  
  should "not list unpublished place availabilities as guest" do
    get "/places/#{@place.id}/availabilities.json"
    assert_response(404)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
  end
  
  should "list unpublished place availabilities as admin" do
    get "/places/#{@place.id}/availabilities.json", :access_token => @admin_user.authentication_token
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_not_nil json['availabilities']  
    assert_equal @availability.id, json['availabilities'][0]["id"]
  end

end