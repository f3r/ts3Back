class AddTypeToAvailability < ActiveRecord::Migration
  def change
    add_column :availabilities, :availability_type, :int
  end
end
