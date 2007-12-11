require File.dirname(__FILE__) + '/../test_helper'

class CommentingTest < Test::Unit::TestCase
  fixtures :commentings, :comments, <%= commentable_models[0..1].join(", ") -%>

  def setup
    @obj1 = <%= model_two %>.find(1)
    @obj2 = <%= model_two %>.find(2)
<% if commentable_models.size > 1 -%>
    @obj3 = <%= model_one -%>.find(1)
<% end -%>
    @comment1 = Comment.find(1)  
    @comment2 = Comment.find(2)  
    @commenting1 = Commenting.find(1)
  end

  def test_commentable
    assert_raises(RuntimeError) do 
      @commenting1.send(:commentable?, true) 
    end
    assert !@commenting1.send(:commentable?)
<% if commentable_models.size > 1 -%>
    assert @obj3.send(:commentable?)
<% end -%>
<% if options[:self_referential] -%>  
    assert @comment1.send(:commentable?)
<% end -%>    
  end
    
end
