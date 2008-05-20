require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :taggings, :tags, <%= taggable_models[0..1].join(", ") -%>

  def setup
    @obj1 = <%= model_two %>.find(1)
    @obj2 = <%= model_two %>.find(2)
<% if taggable_models.size > 1 -%>
    @obj3 = <%= model_one -%>.find(1)
<% end -%>
    @tag1 = Tag.find(1)  
    @tag2 = Tag.find(2)  
    @tagging1 = Tagging.find(1)
  end

  def test_tag_with
    @obj2.tag_with "dark columbian"
    assert_equal "columbian dark", @obj2.tag_list
  end
  
<% if options[:self_referential] -%>  
  def test_self_referential_tag_with
    @tag1.tag_with [1, 2]
    assert @tag1.tags.include?(@tag1)
    assert !@tag2.tags.include?(@tag1)
  end

<% end -%>
  def test__add_tags
    @obj1._add_tags "porter longneck"
    assert Tag.find_by_name("porter").taggables.include?(@obj1)
    assert Tag.find_by_name("longneck").taggables.include?(@obj1)
    assert_equal "delicious longneck porter", @obj1.tag_list    
    
    @obj1._add_tags [2]
    assert_equal "delicious longneck porter sexy", @obj1.tag_list        
  end
  
  def test__remove_tags
    @obj2._remove_tags ["2", @tag1]
    assert @obj2.tags.empty?
  end
  
  def test_tag_list
    assert_equal "delicious sexy", @obj2.tag_list
  end
    
  def test_taggable
    assert_raises(RuntimeError) do 
      @tagging1.send(:taggable?, true) 
    end
    assert !@tagging1.send(:taggable?)
<% if taggable_models.size > 1 -%>
    assert @obj3.send(:taggable?)
<% end -%>
<% if options[:self_referential] -%>  
    assert @tag1.send(:taggable?)
<% end -%>    
  end
    
end
