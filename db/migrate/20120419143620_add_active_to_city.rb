class AddActiveToCity < ActiveRecord::Migration
  def change
    add_column :cities, :active, :boolean, :default => false

  end
end
