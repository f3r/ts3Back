class MigrateSerializedPhotos < ActiveRecord::Migration
  def up
    Place.all.each do |place|
      photos = YAML::load(place.photos_old) unless place.photos_old.blank?
      if !photos.blank?
        photos.each do |row|
          photo = row["photo"]
          photo_url = photo["original"].gsub('https', 'http')
          unless Photo.exists?(photo['id'])
            puts "Regenerating photo: #{photo['id']}"
            p = Photo.new(
              :place_id => place.id,
              :name => photo["name"],
              :remote_photo_url => photo_url)
            p.id = photo['id']
            begin
              unless p.save
                puts "Couldn't upload photo: #{photo_url}"
              end
            rescue Exception => e
              puts e.inspect
            end
          end
        end
      end
    end
  end
  
  def down
    Photo.delete_all
  end
end
