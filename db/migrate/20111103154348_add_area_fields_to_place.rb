class AddAreaFieldsToPlace < ActiveRecord::Migration
  def change
    rename_column :places, :sqm, :size
    add_column :places, :size_sqm, :float
    add_column :places, :size_sqf, :float
    add_column :places, :size_unit, :string
  end
end
