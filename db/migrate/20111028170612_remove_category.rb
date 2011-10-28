class RemoveCategory < ActiveRecord::Migration
  def up
    drop_table :categories
  end

  def down
    create_table "categories", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ancestry"
      t.integer  "ancestry_depth", :default => 0
    end
    add_index "categories", ["ancestry"], :name => "index_categories_on_ancestry"    
  end
end
