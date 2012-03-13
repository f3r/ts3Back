class ReviewsController < ApiController
  
  def initialize
    @fields = [:id, :comment, :private, :accuracy, :cleanliness, :checkin, :communication, :location, :value, :created_at]
    @user_fields = [:id, :first_name, :last_name, :avatar_file_name, :role]
  end
  
  # == Description
  # Returns all the reviews of a place
  # ==Resource URL
  # /places/:place_id/reviews.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/reviews.json
  # === Parameters
  # none
  # ==Errors
  # [106] not found
  # [115] no results
  def index
    place = Place.with_permissions_to(:read).find(params[:id])
    reviews = place.reviews.with_permissions_to(:read)
    if reviews.length > 0
      return_message(200, :ok, {:reviews => filter_fields(reviews, @fields, { 
        :additional_fields => { :user => @user_fields } 
      })})
    else
      return_message(200, :ok, {:err => {:reviews => [115]}})
    end
  end

  # == Description
  # Posts a new review for a place
  # ==Resource URL
  # /places/:place_id/reviews.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places/123/reviews.json access_token=access_token&comment=my+review+here&private=1&value=5
  # === Parameters
  # [access_token]
  # [value]         Integer, rating value 1-5
  # [private]       Boolean, private review true or false
  # [comment]       Text, the review comment
  # == Errors
  # [101] can't be blank 
  # [106] not found
  def create
    place = Place.with_permissions_to(:read).find(params[:id])
    new_params = filter_params(params, @fields)
    review = place.reviews.new(new_params)
    review.user = current_user
    if review.save
      return_message(200, :ok, {
        :review => filter_fields(review, @fields, { 
          :additional_fields => { :user => @user_fields } 
        })
      })
    else
      return_message(200, :fail, {:err => format_errors(review.errors.messages)})
    end
  end

  # == Description
  # Deletes a review
  # ==Resource URL
  # /places/:place_id/review/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/places/123/reviews/:id.json access_token=access_token
  # === Parameters
  # [access_token]
  def destroy
    review = Review.find(params[:review_id])
    if review.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(review.errors.messages)})
    end
  end
end