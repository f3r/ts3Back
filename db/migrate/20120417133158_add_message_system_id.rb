class AddMessageSystemId < ActiveRecord::Migration
  def change
    add_column :messages, :system_msg_id, :string
  end
end
