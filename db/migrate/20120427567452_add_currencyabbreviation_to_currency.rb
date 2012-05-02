class AddCurrencyabbreviationToCurrency < ActiveRecord::Migration
  def change
    add_column :currencies, :currency_abbreviation, :string

  end
end
