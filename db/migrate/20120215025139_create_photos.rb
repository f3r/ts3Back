class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.references :place
      t.string :name
      #t.string :photo
      t.has_attached_file :photo
      t.integer :position
    end
  end

  def self.down
    drop_table :photos
  end
end
