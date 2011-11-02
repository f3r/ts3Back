class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.timestamps
    end
    add_column :availabilities, :place_id,        :integer
    add_column :availabilities, :date_start,      :date
    add_column :availabilities, :date_end,        :date
    add_column :availabilities, :price_per_night, :integer, :null => true
    add_column :availabilities, :comment,         :string,  :null => true

    add_index  :availabilities, :place_id
  end
end
