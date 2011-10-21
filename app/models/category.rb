class Category < ActiveRecord::Base
  include GeneralHelper
  validates_uniqueness_of :name, :scope => :ancestry, :message => "100"
  validates_presence_of :name, :message => "101"
  attr_accessible :name, :parent
  has_ancestry :cache_depth => true
  after_commit :delete_cache

  def self.category_tree
    tree = []
    roots.map{|x| tree << category_tree_rec(x)}
    return tree
  end
  
  def self.category_tree_rec(cat)
    if cat.has_children?
      children = []
      cat.children.map{ |x| children << category_tree_rec(x) }
      return {:id => cat.id, :name => cat.name, :children => children}
    else
      return {:id => cat.id, :name => cat.name}
    end
  end

  private
  
  def delete_cache
    delete_caches(["category/list"])
  end

end