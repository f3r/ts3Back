class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.references :user
      t.references :place
      t.date :check_in
      t.date :check_out
      t.text :extra

      t.timestamps
    end
    add_index :inquiries, :user_id
    add_index :inquiries, :place_id
  end
end
