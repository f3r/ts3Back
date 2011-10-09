require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  test "should not save category with empty title" do
    category = Category.new
    assert !category.save
  end

end