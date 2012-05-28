require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IsTaggableTest < ActiveSupport::TestCase
  fixtures :todos, :recurring_todos
  
  def test_models_are_taggable
    assert Todo.find(:first).respond_to?(:tag_list)
    assert RecurringTodo.find(:first).respond_to?(:tag_list)
  end
  
  def test_test_to_s
    t = Todo.create(:description => "test", :context => Context.first)
    t.tag_list = "one, two, three"
    
    # tags will be sorted alphabetical
    assert_equal "one, three, two", t.tag_list
    assert_equal "one, three, two", t.tags.to_s
  end
  
  def test_getting_all_tags_except_starred
    t = Todo.create(:description => "test", :context => Context.first)
    t.tag_list = "one, two, three"
    t.toggle_star!
    
    assert_equal "one, starred, three, two", t.tag_list
    assert_equal "one, three, two", t.tags.all_except_starred.map(&:name).sort.join(", ")
  end
  
  def test_editing_tags
    t = Todo.create(:description => "test", :context => Context.first)
    t.tag_list = "a, b, c"

    assert_equal 3, t.tags.count
    
    t.tag_with "a, b"
    
    assert_equal "a, b", t.tag_list, "should remove tag c"
    
    t.tag_with "a, b, c, d"
    assert_equal "a, b, c, d", t.tag_list, "should add c and d"
    
    t.tag_with "a, b, e, f"
    assert_equal "a, b, e, f", t.tag_list, "should add e and f and remove c and d"
  end
  
end