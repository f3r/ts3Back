class AddCommentIdToComments < ActiveRecord::Migration
  def change
     # If it's null means that is a question, not an answer
     add_column :comments, :replying_to, :integer, :null => true
  end
end
