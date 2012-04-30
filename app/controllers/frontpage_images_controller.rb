class FrontpageImagesController < ApiController
  filter_access_to :all, :attribute_check => false
  respond_to :xml, :json
  
  def get_visible_images
    fields = [:id, :link, :label, :created_at]
    visible_images = FrontCarrousel.where(:active => true).all()
    
    images = []
    visible_images.each{ |image|
          filtered_image_object = filter_fields(image, fields)
          filtered_image_object[:image_url] = image.image_url
          images << filtered_image_object
    }
    
    return_message(200, :ok, {:images => images})
  end

end