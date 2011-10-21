class ItemsController < ApplicationController
  respond_to :xml, :json
  
  # == Description
  # Returns and array of product images relating to a certain query
  # ==Resource URL
  # /items/image_search.format
  # ==Example
  # GET https://backend-heypal.heroku.com/items/image_search.json query=Harry Potter
  # === Parameters
  # [:query]
  def image_search
    client = ASIN::Client.instance
    #TODO: Check if the split(' ') is good or rather we have to do: split('%20')
    amazon_response = Rails.cache.fetch("image_search/#{params[:query]}") {
       client.search_keywords params[:query].split(' ')
     }
    images = []
    amazon_response.each {|item|
       images << {:image => item.image_url}
    }
    
    respond_with do |format|
      if images.nil?
        response = { :stat => "ok", :images => images }
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
      end
    end
  end
end
