class Category < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name
  has_ancestry :cache_depth => true

  def category_tree(cat)
    if cat.has_children?
      children = []
      cat.children.each {|child|
        children << category_tree(child)
      }
      return {:id => cat.id, :name => cat.name, :children => children}
    else
      return {:id => cat.id, :name => cat.name}
    end
  end
end