class AddPrefCityToUser < ActiveRecord::Migration
  def change
    add_column :users, :pref_city, :integer

  end
end
