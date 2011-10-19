class ItemsController < ApplicationController
  respond_to :xml, :json
  
  #TODO: very good candidate for adding caching --> Rails.cache.write('amazon/#{query}', images)
  def image_search
    client = ASIN::Client.instance
    #TODO: Check if the split(' ') is good or rather we have to do: split('%20')
    amazon_response = client.search_keywords params[:query].split(' ')
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
