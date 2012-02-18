class PhotosController < ApiController

  before_filter :get_place, :except => [:destroy]
  
  def initialize
    @fields = [:id, :name, :place_id, :created_at]
    @user_fields = [:id, :first_name, :last_name, :avatar_file_name, :role]
  end
  
  # == Description
  # Returns all the photos for a place
  # ==Resource URL
  # /places/:place_id/photos.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/photos.json
  # === Parameters
  # none
  # ==Errors
  # [106] not found
  # [115] no results
  def index
    @photos = @place.photos
    return_message(200, :ok, {:photos => @photos})
  end

  # == Description
  # Upload a new photo for a place
  # ==Resource URL
  # /places/:place_id/photos.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places/123/photos.json access_token=access_token
  # === Parameters
  # [access_token]
  # [photo]        File, photo file
  # == Errors
  # [101] can't be blank
  # [106] not found (place or replying_to comment, if passed)
  def create
    @photo = @place.photos.new(:photo => params[:photo])
    if @photo.save
      return_message(200, :ok, {:photo => filter_fields(@photo,@fields)} )
    else
      return_message(200, :fail, {:err => format_errors(@photo.errors.messages)})
    end
  end

  # == Description
  # Deletes a photo
  # ==Resource URL
  # /photos/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/places/123/photo/:id.json access_token=access_token
  # === Parameters
  # [access_token]
  def destroy
    @photo = Photo.find(params[:id])
    if @photo.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(@photo.errors.messages)})
    end
  end
  
  def update
    @photo = Photo.find(params[:id])
    @photo.name = params[:name]
    if @photo.save
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(@photo.errors.messages)})
    end
  end

  # == Description
  # Changes the order of photos
  # ==Resource URL
  # /places/:place_id/photos/sort.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/places/123/photos/:sort.json access_token=access_token
  # === Parameters
  # [access_token]
  # [photo_ids]     The ids of the photos in the desired order
  def sort
    if @place.photos.set_positions(params[:photo_ids])
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(@place.errors.messages)})
    end
  end
  
  protected
  
  def get_place
    @place = Place.with_permissions_to(:read).find(params[:place_id])
  end
end
