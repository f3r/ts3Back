class BackupPhotosSerializedField < ActiveRecord::Migration
  def up
    rename_column :places, :photos, :photos_old
  end

  def down
    rename_column :places, :photos_old, :photos
  end  
end