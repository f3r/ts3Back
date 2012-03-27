class AddInquiryStayFields < ActiveRecord::Migration
  def change
    add_column :inquiries, :length_stay, :integer
    add_column :inquiries, :length_stay_type, :string
    add_column :inquiries, :guests, :integer
  end
end
