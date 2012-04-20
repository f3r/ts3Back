class AddActiveToCity < ActiveRecord::Migration
  def self.up
    add_column :cities, :active, :boolean, :default => false
    City.unscoped.first.activate!
  end

  def self.down
    remove_column :cities, :active
  end
end
