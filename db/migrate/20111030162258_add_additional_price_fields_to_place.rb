class AddAdditionalPriceFieldsToPlace < ActiveRecord::Migration
  def change
    add_column :places, :price_final_cleanup_usd, :integer
    add_column :places, :price_security_deposit_usd, :integer
  end
end
