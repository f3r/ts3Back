class AddPositionToCity < ActiveRecord::Migration
  def change
    add_column :cities, :position, :integer

  end
end
