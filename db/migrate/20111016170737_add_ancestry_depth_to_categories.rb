class AddAncestryDepthToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :ancestry_depth, :integer, :default => 0
  end
end
