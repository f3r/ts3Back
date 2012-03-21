class CreateInboxEntries < ActiveRecord::Migration
  def change
    create_table :inbox_entries do |t|
      t.references :user
      t.references :conversation
      t.boolean :read, default: false
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :inbox_entries, :conversation_id
  end
end
