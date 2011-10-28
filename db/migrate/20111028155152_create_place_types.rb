class CreatePlaceTypes < ActiveRecord::Migration
  def change
    create_table :place_types do |t|
      t.string :name
      t.timestamps
    end
    PlaceType.create([{:name => "Apartment"}, {:name => "House"}, {:name => "Villa"}, {:name => "Room"}, {:name => "Shared Room"}, {:name => "Dorm"}, {:name => "Other space"}])
  end
end