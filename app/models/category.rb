class Category < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name
  has_ancestry :cache_depth => true

  def self.category_tree
    return self.first.category_tree_rec(self.first)
  end
  
  def category_tree_rec(cat)
    if cat.has_children?
      children = []
      cat.children.each {|child|
        children << category_tree_rec(child)
      }
      return {:id => cat.id, :name => cat.name, :children => children}
    else
      return {:id => cat.id, :name => cat.name}
    end
  end
end