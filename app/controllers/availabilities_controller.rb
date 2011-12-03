class AvailabilitiesController < ApplicationController
  filter_access_to :all, :attribute_check => false
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  # == Description
  # List all availabilities of a place
  # ==Resource URL
  # /places/:id/availabilities.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/availabilities.json
  # === Parameters
  # [currency]   ISO Code of the currency to return prices in. Optional
  # === Response
  # [availability]
  #   Array containing all availabilities of a place
  #   Availability types: 1: Ocuppied, 2: New price,
  #   Internal use, 3: temporal request, 4: Payed, 5: Confirmed rental
  # == Error codes
  # [106] not found
  # [115] no results
  def list
    @fields = [:id,:availability_type,:date_start,:date_end,:comment,:price_per_night,:comment]
    @place = Place.with_permissions_to(:read).find(params[:id])
    @availabilities = @place.availabilities.order("date_start ASC")
    availabilities = filter_fields(@availabilities, @fields, { :currency => params[:currency] })
    if !availabilities.blank?
      return_message(200, :ok, {:availabilities => availabilities})
    else
      return_message(200, :ok, {:err=>{:availabilities => [115]}} )
    end
  end
  
  # == Description
  # Creates a new availability for a place
  # ==Resource URL
  # /places/:id/availabilities.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places/123/availabilities.json access_token=access_token&date_start=23/01/2011&date_end=12/02/2011
  # === Parameters
  # [access_token]      Access token
  # [availability_type] Integer, Type of availability, possible values are (1: Occupied, 2: New Price)
  # [date_start]        Date (dd/mm/yyyy), Starting date
  # [date_end]          Date (dd/mm/yyyy), Ending Date
  # [price_per_night]   Integer, Price for the period in original currency cents, optional
  # [comment]           String, Comment to describe the period, optional
  # === Response
  # [availability] Array containing the recently created availability
  # == Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  # [119] date must be future, after today
  # [120] end date must be after initial date
  # [121] interval overlaps with existing interval for the place
  def create
    #TODO: Check that the availability is for a place the user owns...
    
    availability = {}     
    availability.merge!({ :availability_type => params[:availability_type]})
    availability.merge!({ :date_start        => params[:date_start]})
    availability.merge!({ :date_end          => params[:date_end]})
    availability.merge!({ :price_per_night   => params[:price_per_night]}) if params[:price_per_night]
    availability.merge!({ :comment           => params[:comment]})         if params[:comment]
    
    @availability = Place.with_permissions_to(:update).find(params[:id]).availabilities.new(availability)
    if @availability.save
      return_message(200, :ok, {:availability => @availability})
    else
      return_message(200, :fail, {:err => format_errors(@availability.errors.messages)})
    end
  end
  
  # == Description
  # Deletes an availability for a place
  # ==Resource URL
  # /places/:place_id/availabilities/:id.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places/123/availabilities/1.json access_token=access_token
  # === Parameters
  # [access_token]      Access token
  def destroy
    @availability = Place.with_permissions_to(:update).find(params[:place_id]).availabilities.find(params[:id])
    if @availability.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(@availability.errors.messages)})
    end
  end
  
  # == Description
  # Updates an availability of a place
  # ==Resource URL
  # /places/:place_id/availabilities/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/places/123/availabilities/2.json access_token=access_token&date_start=23/01/2011&date_end=12/02/2011
  # === Parameters
  # [access_token]     Access token
  # [availability_type] Integer, Type of availability, possible values are (1: Occupied, 2: New Price)
  # [date_start]       Date (dd/mm/yyyy), Starting date
  # [date_end]         Date (dd/mm/yyyy), Ending Date
  # [price_per_night]  Integer, Price for the period in original currency cents
  # [comment]          String, Comment to describe the period
  # === Response
  # [availability] Array containing the recently updated availability
  # == Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  # [106] not found
  # [122] unmatching parent resource and child resource
  def update
    @place        = Place.with_permissions_to(:update).find(params[:place_id])
    @availability = @place.availabilities.find(params[:id])
          
    availability = {}
    availability.merge!({ :date_start        => @availability['date_start'] })
    availability.merge!({ :date_end          => @availability['date_end']   })
    availability.merge!({ :availability_type => params[:availability_type]})
    availability.merge!({ :date_start        => params[:date_start]})      if params[:date_start]
    availability.merge!({ :date_end          => params[:date_end]})        if params[:date_end]
    availability.merge!({ :price_per_night   => params[:price_per_night]}) if params[:price_per_night]
    availability.merge!({ :comment           => params[:comment]})         if params[:comment]

    if @availability.update_attributes(availability)
      return_message(200, :ok, {:availability => @availability})
    else
      return_message(200, :fail, {:err => format_errors(@availability.errors.messages)})
    end
  end
  
end