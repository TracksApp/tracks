require 'test_helper'

class IsTaggableTest < ActiveSupport::TestCase
  fixtures :todos, :recurring_todos
  
  def test_models_are_taggable
    assert Todo.first.respond_to?(:tag_list)
    assert RecurringTodo.first.respond_to?(:tag_list)
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

  def test_editing_using_taglist
    t = Todo.create(:description => "test", :context => Context.first)
    t.tag_list = "a, b, c"
    assert_equal 3, t.tags.count
    assert_equal "a, b, c", t.tag_list


    t.tag_list = "d, e"
    assert_equal 2, t.tags.count
    assert_equal "d, e", t.tag_list
  end
  
  def test_tag_cast_to_string
    t = Todo.create(:description => "test", :context => Context.first)

    obj = "tag"
    assert_equal ["tag"], t.tag_cast_to_string(obj)

    obj = ["tag1", Tag.new(name: "tag2")]
    assert_equal ["tag1", "tag2"], t.tag_cast_to_string(obj)

    obj = {a: "hash"}
    assert_raise(RuntimeError) { t.tag_cast_to_string(obj) } 

    obj = ["string", {a: "hash"}]
    assert_raise(RuntimeError) { t.tag_cast_to_string(obj) } 
  end

end