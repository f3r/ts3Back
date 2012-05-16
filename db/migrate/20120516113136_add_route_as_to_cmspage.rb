class AddRoutesAsToCmspage < ActiveRecord::Migration
  def self.up
    add_column :cmspages, :route_as, :varchar
  end
end
