class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.float :lat, :limit => 53, :null => true
      t.float :lon, :limit => 53, :null => true
      t.string :state
      t.string :country
      t.string :country_code
    end
    add_index :cities, :state
    add_index :cities, :country
    add_index :cities, :country_code
  end
end
