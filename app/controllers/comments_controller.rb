class CommentsController < ApplicationController
  filter_access_to :all, :attribute_check => false
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  def initialize
    @fields = [:id, :user_id, :place_id, :comment, :owner, :created_at]
  end
  
  # == Description
  # Returns all the comments and answer of a place
  # ==Resource URL
  # /places/:place_id/comments.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/123/comments.json
  # === Parameters
  # none
  # ==Errors
  # [106] not found
  # [115] no results
  def index
    # We get all the comments for the place that are questions
    @comments = Comment.with_permissions_to(:read).where(:replying_to => nil, :place_id => params[:id])
    if @comments.count > 0
      # We get all the replies and add them to the answer
      foo = []
      @comments.each{|comment|
        question = filter_fields(comment, @fields + [:comments_count])
        user = User.find(comment.user_id)
        question.merge!({:user => 
          { :name =>  user.full_name,
            :role =>  user.role,
            :photo => user.avatar_file_name
          }
        })
        answers = comment.answers
        if answers
          answers_response = []
          answers.each{|reply|
            user = User.find(reply.user_id)
            bar = ({:user => 
              { :name =>  user.full_name,
                :role =>  user.role,
                :photo => user.avatar_file_name
              }
            })
            answers_response << (filter_fields(reply,@fields)).merge!(bar)
          }
          question.merge!({:replies => answers_response})
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
  # [access_token]
  # [comment]      String, comment that user posts
  # [replying_to]  Optional, Integer, comment_id that the owner replies to
  # == Errors
  # [101] can't be blank 
  # [106] not found (place or replying_to comment, if passed)
  def create
    place = Place.with_permissions_to(:read).find(params[:id])
    comment      = {:user_id     => current_user.id}
    comment.merge!({:comment     => params[:comment]})
    comment.merge!({:owner       => (place.user_id == current_user.id)})
    comment.merge!({:replying_to => params[:replying_to]}) if params[:replying_to]
    @comment = place.comments.new(comment)
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
  # [access_token]
  # [comment]  New comment
  # == Errors
  # [101] can't be blank 
  def update
    @comment = Comment.find(params[:id])
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
  # [access_token]
  def destroy
    @comment = Comment.find(params[:id])
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
