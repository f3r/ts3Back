# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "places/#{model.place_id}/photos/#{model.id}/"
    #places/:id/photos/:uniq_id/:style.:extension
  end

  version :tiny do
    process :resize_to_fill => [40,40]
  end
  
  version :small do
    process :resize_to_fill => [105,70]
  end
  
  version :medsmall do
    process :resize_to_fill => [150,100]
  end
  
  version :medium do
    process :resize_to_fill => [309,200]
  end
  
  version :large do
    process :watermark => "#{Rails.root}/public/images/watermark_icon.png"
    process :resize_to_fill => [602,401]
  end
  
  #:large => {
  #  :geometry => "602x401>",
  #  :watermark_path => "#{Rails.root}/public/images/watermark_icon.png"
  #},
  #:medium => "309x200#",
  #:medsmall => "150x100#",
  #:small => "105x70#",
  #:tiny => "40x40#"
  #:path => "places/:id/photos/:uniq_id/:style.:extension"
    
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
