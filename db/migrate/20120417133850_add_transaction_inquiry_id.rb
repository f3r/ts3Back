class AddTransactionInquiryId < ActiveRecord::Migration
  def change
    add_column :transactions, :inquiry_id, :integer
  end
end
