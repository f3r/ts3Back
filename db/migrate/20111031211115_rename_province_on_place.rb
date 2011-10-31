class RenameProvinceOnPlace < ActiveRecord::Migration
  def change
    rename_column :places, :province_id, :state_id
  end
end
