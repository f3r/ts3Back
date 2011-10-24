class AddressesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  def initialize
    @fields = [:id, :street, :city, :country, :zip]
  end
  
  # == Description
  # Returns all the addresses of the current user
  # ==Resource URL
  # /users/addresses.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/addresses.json
  # === Parameters
  # [:access_token]
  def index
    check_token
    @addresses = current_user.addresses.select(@fields)
    respond_with do |format|
      response = @addresses.count > 0 ? { :stat => "ok", :addresses => @addresses } : { :stat => "ok", :err => {:address => [115]} }
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end

  # == Description
  # Creates a new address for the current user, must include street name, city, country and zip code
  # ==Resource URL
  # /users/addresses.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/addresses.json access_token=access_token&street=street&city=city&country=country&zip=zip
  # === Parameters
  # [:access_token]
  # [:street]  Street name and number of the user
  # [:city]    City name
  # [:country] Country Name
  # [:zip]     Zip Code
  # == Errors
  # [:101] can't be blank 
  # [:116] Duplicate address
  def create
    check_token
    @address = current_user.addresses.new(
      :street  => params[:street],
      :city    => params[:city],
      :country => params[:country],
      :zip     => params[:zip]
      )

    respond_with do |format|
      if @address.save
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat        => "ok", 
            :address     => filter_fields(@address, @fields)
          },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@address.errors.messages) },
          request.format.to_sym)}
      end
    end
  end

  # == Description
  # Updates one of the current user's Addresses
  # ==Resource URL
  # /users/addresses/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users/addresses/:id.json access_token=access_token&street=street&city=city&country=country&zip=zip
  # === Parameters
  # [:access_token]
  # [:street]  Street name and number of the user
  # [:city]    City name
  # [:country] Country Name
  # [:zip]     Zip Code
  # == Errors
  # [:101] can't be blank 
  # [:116] Duplicate address
  def update
    check_token
    @address = current_user.addresses.find(params[:id])
    respond_with do |format|
      if @address.update_attributes(
          :street  => params[:street],
          :city    => params[:city],
          :country => params[:country],
          :zip     => params[:zip])
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response(
            {  
              :stat        => "ok", 
              :address     => filter_fields(@address, @fields)
            },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@address.errors.messages) },
          request.format.to_sym) }
      end
    end
  end

  # == Description
  # Deletes one of the addresses of the current user
  # ==Resource URL
  # /users/addresses/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/users/addresses/:id.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    check_token
    @address = current_user.addresses.find(params[:id])
    respond_with do |format|
      if @address.destroy
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok"},
          request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@address.errors.messages) },
            request.format.to_sym) }
      end
    end
  end
end