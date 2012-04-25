class AddPositionToCurrency < ActiveRecord::Migration
  def change
    add_column :currencies, :position, :integer

  end
end
