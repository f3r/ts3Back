class AddPriceSquareFootToPlace < ActiveRecord::Migration
  def change
    add_column :places, :price_sqf_usd, :float
  end
end
