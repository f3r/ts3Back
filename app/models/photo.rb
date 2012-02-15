class Photo < ActiveRecord::Base
  belongs_to :place
  
  mount_uploader :photo, PhotoUploader
  
  #validates_presence_of :place_id
  
  def as_json(opts = {})
    photo_hash = {:name => self.name, :original => self.photo.url}
    [:tiny, :small, :medsmall, :medium, :large].each do |version|
      photo_hash[version] = self.photo.url(version)
    end
    
    {:photo => photo_hash}
  end
end
