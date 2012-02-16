class Photo < ActiveRecord::Base
  belongs_to :place
  
  #mount_uploader :photo, PhotoUploader
  
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
     :path => "places/:place_id/photos/:id/:style.:extension",
     :processors => [:rationize, :watermark]
   }
  
  #validates_presence_of :place_id
  
  def as_json(opts = {})
    photo_hash = {:name => self.name, :original => self.photo.url}
    [:tiny, :small, :medsmall, :medium, :large].each do |version|
      photo_hash[version] = self.photo.url(version)
    end
    
    {:photo => photo_hash}
  end
  
  def remote_photo_url=(url)
    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    self.photo = io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    logger.error "Cannot fetch #{url}"
  end
end