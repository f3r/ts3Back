class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :conversation
      t.integer :from_id
      t.text :body

      t.timestamps
    end
    add_index :messages, :conversation_id
  end
end
