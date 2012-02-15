class MigrateSerializedPhotos < ActiveRecord::Migration
  def up
    Place.all.each do |place|
      photos_old = YAML::load(place.photos_old)
      if !photos_old.blank?
        photos_old.each do |row|
          photo = row["photo"]
          Photo.create!(
            :id => photo["id"],
            :place_id => place.id,
            :name => photo["name"],
            :remote_photo_url => photo["original"])
        end
      end
    end
  end

  def down
    Photo.delete_all
  end
end
