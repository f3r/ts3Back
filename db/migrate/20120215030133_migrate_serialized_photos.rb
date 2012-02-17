class MigrateSerializedPhotos < ActiveRecord::Migration
  # def up
  #   Place.all.each do |place|
  #     photos_old = YAML::load(place.photos_old)
  #     if !photos_old.blank?
  #       photos_old.each do |row|
  #         photo = row["photo"]
  #         p = Photo.new(
  #           :place_id => place.id,
  #           :name => photo["name"],
  #           :remote_photo_url => photo["original"].gsub('https', 'http'))
  #         p.id = photo['id']
  #         #p.save!
  #       end
  #     end
  #   end
  # end
  # 
  # def down
  #   Photo.delete_all
  # end
end
