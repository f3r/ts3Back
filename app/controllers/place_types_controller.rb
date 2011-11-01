class PlaceTypesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  def initialize
    @fields = [:id, :name]
  end

  # ==Resource URL
  # /place_types.format
  # ==Example
  # GET https://backend-heypal.heroku.com/place_types.json
  # === Parameters
  # None
  def index
    @place_types = PlaceType.select(@fields).all
    respond_with do |format|
      response = @place_types.count > 0 ? { :stat => "ok", :place_types => @place_types } : { :stat => "ok", :err => {:states => [115]} }
      format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end

  # ==Resource URL
  # /place_types.format
  # ==Example
  # POST https://backend-heypal.heroku.com/place_types.json access_token=access_token&name=name
  # === Parameters
  # [:access_token]
  # [:name]
  def create
    check_token
    @place_type = PlaceType.new(:name => params[:name])
    respond_with do |format|
      if @place_type.save
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :place_type => filter_fields(@place_type, @fields) },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@place_type.errors.messages) },
          request.format.to_sym)}
      end
    end
  end

  # ==Resource URL
  # /place_types/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/place_types/:id.json access_token=access_token&name=name
  # === Parameters
  # [:access_token]
  # [:name]
  def update
    check_token
    @place_type = PlaceType.find(params[:id])
    respond_with do |format|
      if @place_type.update_attributes(:name => params[:name])
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :place_type => filter_fields(@place_type, @fields) },
          request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@place_type.errors.messages) },
          request.format.to_sym) }
      end
    end
  end

  # ==Resource URL
  # /place_types/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/place_types/:id.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    check_token
    @place_type = PlaceType.find(params[:id])
    respond_with do |format|
      if @place_type.destroy
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :place_type => filter_fields(@place_type, @fields) },
          request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@place_type.errors.messages) },
          request.format.to_sym) }
      end
    end
  end
end