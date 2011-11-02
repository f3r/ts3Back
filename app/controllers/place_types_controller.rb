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
    if @place_types.count > 0
      return_message(200, :ok, {:place_types => @place_types})
    else
      return_message(200, :ok, {:err => {:states => [115]}})
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

    if @place_type.save
      return_message(200, :ok, {:place_type => filter_fields(@place_type, @fields)})
    else
      return_message(200, :fail, {:err => format_errors(@place_type.errors.messages)})
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
    if @place_type.update_attributes(:name => params[:name])
      return_message(200, :ok, {:place_type => filter_fields(@place_type, @fields)})
    else
      return_message(200, :fail, {:err => format_errors(@place_type.errors.messages)})
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
    if @place_type.destroy
      return_message(200, :ok, {:place_type => filter_fields(@place_type, @fields)})
    else
      return_message(200, :fail, {:err => format_errors(@place_type.errors.messages)})
    end
  end
end