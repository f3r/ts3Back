class AddCompleteNameToCity < ActiveRecord::Migration
  def change
    add_column :cities, :cached_complete_name, :string
  end
end
