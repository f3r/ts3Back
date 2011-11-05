class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.timestamps
    end
    add_column :comments,   :user_id,   :integer
    add_column :comments,   :place_id,  :integer
    add_column :comments,   :comment,   :text
    add_column :comments,   :owner,     :boolean

    add_index  :comments,   :user_id
    add_index  :comments,   :place_id
  end
end
