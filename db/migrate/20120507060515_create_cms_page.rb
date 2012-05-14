class CreateCmsPage < ActiveRecord::Migration
  def change
  create_table :cmspages do |t|
      t.string :page_title
      t.string :page_url, :null => false, :default => ""
      t.text   :description 
      t.boolean:active, :default => false      
  end
      add_index :cmspages, :page_url,                :unique => true
  end
  
end
