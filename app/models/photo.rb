class Photo < ActiveRecord::Base
  belongs_to :place

  after_destroy :update_place_status

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
     :convert_options => { 
        :all => "-quality 70"
      },
     :path => "places/:place_id/photos/:id/:style.:extension",
     :processors => [:rationize, :watermark]
   }
  
  #validates_presence_of :place_id
  
  def self.set_positions(photo_ids)
    photo_ids.each_with_index do |photo_id, idx|
      self.find(photo_id).update_attribute(:position, idx + 1)
    end
    true
  end
  
  def as_json(opts = {})
    photo_hash = {:id => self.id, :name => self.name, :original => self.photo.url}
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

  protected

  def update_place_status
    if self.place && self.place.photos.count < 3
      self.place.update_attribute(:published, false)
    end
  end
end