class FrontCarrousel < ActiveRecord::Base

  has_attached_file :photo, {
     :styles => {
       :large => {
         :geometry => "602x401>"
       },
       :tiny => "40x40#"
     },
     :convert_options => { 
        :all => "-quality 70"
      },
     :path => "front/photos/:id/:style.:extension",
     :processors => [:rationize, :watermark]
   }
  
end