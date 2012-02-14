class Photo < ActiveRecord::Base
  belongs_to :place

  has_attached_file :photo, {
    :styles => {
      :large => {
        :geometry => "602x401>",
        :watermark_path => "#{Rails.root}/public/images/watermark_icon.png"
      },
      :medium => "309x200#",
      :medsmall => "150x100#",
      :small => "105x70#",
      :tiny => "40x40#"
    }, 
    :path => "places/:id/photos/:uniq_id/:style.:extension"
  }
  
  #def as_json
  #  
  #end
end
