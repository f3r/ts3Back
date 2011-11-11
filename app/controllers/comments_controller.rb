class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  def initialize
    @fields = [:id, :user_id, :place_id, :comment, :owner, :created_at, :replying_to]
  end
  
  # == Description
  # Returns all the comments and answer of a place
  # ==Resource URL
  # /places/:place_id/comments.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/comments.json
  # === Parameters
  # none
  def index
    # We get all the comments for the place that are questions
    @comments = Place.find(params[:id]).comments.where(:replying_to => nil).order("created_at ASC")
    if @comments.count > 0
      # We get all the replies and add them to the answer
      foo = []
      @comments.each{|comment|
        question = filter_fields(comment,@fields)
        replies  = Comment.where(:replying_to => comment.id)
        if replies
          replies_response = {}
          replies.each{|reply|
            replies_response.merge!(filter_fields(reply,@fields)) 
          }
          question.merge!({:replies => replies_response})
          foo = foo << question
        else
          foo.merge!(question) 
        end
      }
      return_message(200, :ok, {:comments => foo})
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
  # [:comment]      String, comment that user posts
  # [:replying_to]  Optional, Integer, comment_id that the owner replies to
  # == Errors
  # [:101] can't be blank 
  # [:106] not found (place or replying_to comment, if passed)
  def create
    check_token
    place = Place.find(params[:id])

    comment      = {:user_id     => current_user.id}
    comment.merge!({:comment     => params[:comment]})
    comment.merge!({:owner       => (place.user_id == current_user.id)})
    comment.merge!({:replying_to => params[:replying_to]}) if params[:replying_to]
    @comment = Place.find(params[:id]).comments.new(comment)

    if @comment.save
      return_message(200, :ok, {:comment => filter_fields(@comment,@fields)} )
    else
      return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
    end
  end

  # == Description
  # Updates the content of a comment. Note: you can't update user or place or replying_to
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
    @comment = current_user.comments.find(params[:id])
    if @comment.update_attributes(:comment  => params[:comment])
      return_message(200, :ok, {:comment => filter_fields(@comment,@fields)})  
    else
      return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
    end
  end

  # == Description
  # Deletes a comment and all the replies, if any
  # ==Resource URL
  # /places/:place_id/comment/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/places/123/comments/:id.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    check_token
    @comment = current_user.comments.find(params[:id])
    # We find all the replies
    @replies = Comment.where("replying_to = #{params[:id]}").all
    if @comment.destroy
      error = false
      @replies.each{|reply|
        error=true if !reply.destroy
      }
      if error
        return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
      else
        return_message(200, :ok)
      end
    else
      return_message(200, :fail, {:err => format_errors(@comment.errors.messages)})
    end
  end
end
