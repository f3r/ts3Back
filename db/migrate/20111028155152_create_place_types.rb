class CreatePlaceTypes < ActiveRecord::Migration
  def change
    create_table :place_types do |t|
      t.string :name
      t.timestamps
    end
    
    require 'declarative_authorization/maintenance'
    Authorization::Maintenance.without_access_control do
      PlaceType.create([{:name => "Apartment"}, {:name => "House"}, {:name => "Villa"}, {:name => "Room"}, {:name => "Other space"}])
    end
  end
end