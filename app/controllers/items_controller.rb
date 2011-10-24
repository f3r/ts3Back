class ItemsController < ApplicationController
  respond_to :xml, :json
  
  # == Description
  # Returns and array of product images relating to a certain query
  # ==Resource URL
  # /items/image_search.format
  # ==Example
  # GET https://backend-heypal.heroku.com/items/image_search.json query=harry potter goblet of fire
  # === Parameters
  # [:query] Example: harry potter goblet of fire
  # === Response
  # [:images] Array containing image urls
  # == Errors
  # [:114] Amazon API error
  def image_search
    # FIXME: Caching is not working Error: "singleton can't be dumped / You are trying to cache a Ruby object which cannot be serialized to memcached."
    # TODO: Find a way to disable HTTPI.log
    # images = Rails.cache.fetch("image_search/#{query.parameterize("_")}") {
    #   amazon_search(params[:query], :All)
    # }
    images = amazon_search(params[:query], :All)
    respond_with do |format|
      if images
        response = { :stat => "ok", :images => images }
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response(response,request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({
            :stat => "fail",
            :err => {:amazon => [114]} },
            request.format.to_sym) }
      end
    end
  end

  private
  
  def amazon_search(query, index = :All)
    begin
      images = []
      client = ASIN::Client.instance
      amazon_response = client.search(:Keywords => query.split.uniq, :SearchIndex => index, :ResponseGroup => "Medium").map(&:raw)
      amazon_response.map{|image| images << image.ImageSets.ImageSet.LargeImage.URL rescue nil }
      return images
    rescue Exception => e
      logger.error { "Error [items_controller.rb/amazon_search] #{e.message}" }
      return nil
    end
  end

end