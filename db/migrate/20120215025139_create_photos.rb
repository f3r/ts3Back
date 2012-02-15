class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.references :place
      t.string :name
      t.string :photo
    end
  end

  def self.down
    drop_table :photos
  end
end
