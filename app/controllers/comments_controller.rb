class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  # == Description
  # Returns all the comments of a place
  # ==Resource URL
  # /places/:place_id/comments.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/comments.json
  # === Parameters
  # none
  def index
    @comments = Place.find(params[:id]).comments
    if @comments.count > 0
      return_message(200, :ok, {:comments => @comments})
    else
      return_message(200, :ok, {:err => {:comments => [115]}})
    end
  end

  # == Description
  # Posts a new comment for a place
  # ==Resource URL
  # /places/:place_id/comments.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places/123/comments.json access_token=access_token&comment=my+comment+here
  # === Parameters
  # [:access_token]
  # [:comment]  String, comment that user posts
  # == Errors
  # [:101] can't be blank 
  def create
    check_token
    place = Place.find(params[:id])
    owner = (place.user_id == current_user.id)
    @comment = Place.find(params[:id]).comments.new(
      :user_id => current_user.id,
      :comment => params[:comment],
      :owner   => owner
      )
    if @comment.save
      return_message(200, :ok, {:comment => @comment} )
    else
      return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
    end
  end

  # == Description
  # Updates the content of a comment. Note: you can't update user or place
  # ==Resource URL
  # /places/:place_id/comment/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/places/123/comments/1.json access_token=access_token&comment=new+comment
  # === Parameters
  # [:access_token]
  # [:comment]  New comment
  # == Errors
  # [:101] can't be blank 
  def update
    check_token
    @comment = Comment.find(params[:id])
    if @comment.update_attributes(:comment  => params[:comment])
      return_message(200, :ok, {:comment => @comment})  
    else
      return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
    end
  end

  # == Description
  # Deletes a comment
  # ==Resource URL
  # /places/:place_id/comment/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/places/123/comments/:id.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    check_token
    @comment = Comment.find(params[:id])
    if @comment.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
    end
  end
end
