class ItemsController < ApplicationController
  respond_to :xml, :json
  
  def image_search
    client = ASIN::Client.instance
    amazon_response = client.search_keywords params[:query].split(' ')
    images = []
    amazon_response.each {|item|
       images << {:image => item.image_url}
    }
    
    respond_with do |format|
        response = { :stat => "ok", :images => images }
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end
end
