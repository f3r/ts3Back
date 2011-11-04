class ModifyPlaceGeoColumns < ActiveRecord::Migration
  def up
    remove_column :places, :state_id
    remove_column :places, :country_id

    add_column    :places, :city_name, :string
    add_column    :places, :country_name, :string
    add_column    :places, :state_name, :string
    add_column    :places, :country_code, :string, :limit => 2

    add_index     :places, :city_name
    add_index     :places, :country_name
    add_index     :places, :state_name
    add_index     :places, :country_code
  end

  def down
    remove_column     :places, :country_code
    remove_column     :places, :state_name
    remove_column     :places, :country_name
    remove_column     :places, :city_name

    add_column        :places, :country_id, :integer
    add_column        :places, :state_id, :integer
  end
end