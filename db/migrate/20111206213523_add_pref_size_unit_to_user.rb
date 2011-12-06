class AddPrefSizeUnitToUser < ActiveRecord::Migration
  def change
    add_column :users, :pref_size_unit, :string
  end
end
