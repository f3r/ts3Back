class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.references :target, :polymorphic => true
      t.integer :sender_id

      t.timestamps
    end
  end
end
