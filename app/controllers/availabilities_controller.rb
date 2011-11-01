class AvailabilitiesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  # == Description
  # List all availabilities of a place
  # ==Resource URL
  # /places/:id/availabilities.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/availabilities.json
  # === Response
  # [availability] Array containing the all availabilities
  # == Error codes
  # [106] not found
  def list    
    @place = Place.find(params[:id])
    respond_with do |format|
      if !@place.availabilities.blank?
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :availabilities => @place.availabilities.select("id,date_start,date_end,comment,price_per_night,comment") },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :err => {:availabilities => [115]} },
          request.format.to_sym)}
      end
    end
  end
  
  # == Description
  # Creates a new availability for a place
  # ==Resource URL
  # /places/:id/availabilities.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places/123/availabilities.json access_token=access_token&date_start=23/01/2011&date_end=12/02/2011
  # === Parameters
  # [:access_token]     Access token
  # [:date_start]       Date (dd/mm/yyyy), Starting date
  # [:date_end]         Date (dd/mm/yyyy), Ending Date
  # [:price_per_night]  Integer, Price for the period in original currency cents, optional
  # [:comment]          String, Comment to describe the period, optional
  # === Response
  # [availability] Array containing the recently created availability
  # == Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  def create
    check_token
    availability = { 
      :date_start => params[:date_start],
      :date_end   => params[:date_end]
    }
    availability.merge!({ :price_per_night => params[:price_per_night]}) if params[:price_per_night]
    availability.merge!({ :comment         => params[:comment]})         if params[:comment]
    
    #TODO: Check that the availability is for a place the user owns...
    @availability = Place.find(params[:id]).availabilities.new(availability)
    respond_with do |format|
      if @availability.save
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :availability => @availability },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@availability.errors.messages) },
          request.format.to_sym)}
      end
    end
  end
  
  # == Description
  # Updates an availability of a place
  # ==Resource URL
  # /places/:place_id/availabilities/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/places/123/availabilities/2.json access_token=access_token&date_start=23/01/2011&date_end=12/02/2011
  # === Parameters
  # [:access_token]     Access token
  # [:date_start]       Date (dd/mm/yyyy), Starting date
  # [:date_end]         Date (dd/mm/yyyy), Ending Date
  # [:price_per_night]  Integer, Price for the period in original currency cents
  # [:comment]          String, Comment to describe the period
  # === Response
  # [availability] Array containing the recently updated availability
  # == Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  # [106] not found
  # [122] unmatching parent resource and child resource
  def update
    check_token

    #TODO: Check that the availability is for a place the user owns...
    @place = Place.find(params[:place_id])

    respond_with do |format|
      @availability = @place.availabilities.find(params[:id])
            
      availability = {}
      availability.merge!({ :date_start  => @availability['date_start'] })
      availability.merge!({ :date_end    => @availability['date_end']   })

      # Check if date_start/end is updated, otherwise take original
      availability.merge!({ :date_start      => params[:date_start]})      if params[:date_start]
      availability.merge!({ :date_end        => params[:date_end]})        if params[:date_end]
      availability.merge!({ :price_per_night => params[:price_per_night]}) if params[:price_per_night]
      availability.merge!({ :comment         => params[:comment]})         if params[:comment]

      if @availability.update_attribute(availability)
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :availability => @availability },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@availability.errors.messages) },
          request.format.to_sym)}
      end
    end
  end
  
end