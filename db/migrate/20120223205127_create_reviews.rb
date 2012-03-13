class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :place
      t.references :user
      t.float :accuracy, :default => nil
      t.float :cleanliness, :default => nil
      t.float :checkin, :default => nil
      t.float :communication, :default => nil
      t.float :location, :default => nil
      t.float :value, :default => nil
      t.boolean :private, :default => false
      t.text :comment
      t.timestamps
    end
    add_index :reviews, :place_id
    add_index :reviews, :user_id
  end
end