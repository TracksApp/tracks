require File.dirname(__FILE__) + '/test_helper'

class RecordTagHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TextHelper
  include SimplyHelpful::RecordTagHelper
  include SimplyHelpful::RecordIdentificationHelper
  
  def setup
    @record = Post.new
  end
  
  def test_content_tag_for_with_new_record
    _erbout = ''
    content_tag_for(:li, @record) {}
    
    expected = "<li class='post' id='new_post'></li>"
    assert_dom_equal expected, _erbout
  end
  
  def test_content_tag_for_with_existing_record
    @record.save
    _erbout = ''
    content_tag_for(:li, @record) {}
    
    expected = "<li class='post' id='post_1'></li>"
    assert_dom_equal expected, _erbout
  end
  
  def test_content_tag_for_merges_given_class_names
    _erbout = ''
    content_tag_for(:li, @record, :class => 'foo') {}
    
    expected = "<li class='post foo' id='new_post'></li>"
    assert_dom_equal expected, _erbout

    _erbout = ''
    content_tag_for(:li, @record, :class => 'foo bar') {}
    
    expected = "<li class='post foo bar' id='new_post'></li>"
    assert_dom_equal expected, _erbout
  end
  
  def test_content_tag_for_with_dom_id_prefix_on_new_record
    _erbout = ''
    content_tag_for(:li, @record, :foo, :class => 'foo') {}
    
    expected = "<li class='post foo' id='foo_post'></li>"
    assert_dom_equal expected, _erbout
  end
  
  def test_content_tag_for_with_dom_id_prefix_on_existing_record
    @record.save
    _erbout = ''
    content_tag_for(:li, @record, :foo, :class => 'foo') {}
    
    expected = "<li class='post foo' id='foo_post_1'></li>"
    assert_dom_equal expected, _erbout
  end
  
  def test_div_for_with_new_record
    _erbout = ''
    div_for(@record) {}
    
    expected = "<div class='post' id='new_post'></div>"
    assert_dom_equal expected, _erbout
  end

  def test_div_for_with_existing_record
    @record.save
    _erbout = ''
    div_for(@record) {}
    
    expected = "<div class='post' id='post_1'></div>"
    assert_dom_equal expected, _erbout
  end
  
  def test_div_for_merges_given_class_names
    _erbout = ''
    div_for(@record, :class => 'foo') {}
    
    expected = "<div class='post foo' id='new_post'></div>"
    assert_dom_equal expected, _erbout

    _erbout = ''
    div_for(@record, :class => 'foo bar') {}
    
    expected = "<div class='post foo bar' id='new_post'></div>"
    assert_dom_equal expected, _erbout
  end
  
  def test_div_for_with_dom_id_prefix_on_new_record
    _erbout = ''
    div_for(@record, :foo, :class => 'foo') {}
    
    expected = "<div class='post foo' id='foo_post'></div>"
    assert_dom_equal expected, _erbout
  end
  
  def test_div_for_with_dom_id_prefix_on_existing_record
    @record.save
    _erbout = ''
    div_for(@record, :foo, :class => 'foo') {}
    
    expected = "<div class='post foo' id='foo_post_1'></div>"
    assert_dom_equal expected, _erbout
  end
  
  def test_link_to_with_new_record
    actual = link_to :name, @record
    
    expected = "<a href='http://www.example.com/posts'>new post</a>"
    assert_dom_equal expected, actual
  end
  
  def test_link_to_with_existing_record
    @record.save
    actual = link_to :name, @record
    
    expected = "<a href='http://www.example.com/posts/1'>post #1</a>"
    assert_dom_equal expected, actual
  end
  
  def test_link_to_with_an_existing_method_and_constant_text
    @record.save
    actual = link_to "Cancel Editing", @record
    
    expected = "<a href='http://www.example.com/posts/1'>Cancel Editing</a>"
    assert_dom_equal expected, actual
  end
end