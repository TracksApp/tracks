require File.dirname(__FILE__) + '/test_helper'
require 'prototype_helper_patches'
require 'scriptaculous_helper_patches'
require 'ujs/behaviour_helper'

class MakeSortableTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  
  def setup
    initialize_test_request
  end
  
  def test_should_output_sortable_javascript
    output = make_sortable
    
    assert_equal sortable_element_js(javascript_variable('this')), output
  end
  
  def test_should_pass_arguments_through
    output = make_sortable :onUpdate => 'function() { alert("updated") }'
    assert_equal 'Sortable.create(this, {onUpdate:function() { alert("updated") }});', output
  end
end

class MakeRemoteLinkTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  
  def setup
    initialize_test_request
  end
  
  def test_should_generate_ajax_request
    output = make_remote_link
    assert_match(/new Ajax\.Request/, output)
  end
  
  def test_should_default_to_element_href
    output = make_remote_link
    assert_match(/\(this\.href/, output)
  end
  
  def test_should_respond_to_given_options
    output = make_remote_link( :update => 'fartknocker' )
    assert_match(/new Ajax\.Updater\('fartknocker'/, output)
  end
end

class MakeRemoteFormTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  
  def setup
    initialize_test_request
  end
  
  def test_should_generate_ajax_request
    output = make_remote_form
    assert_match(/new Ajax\.Request/, output)
  end
  
  def test_should_default_to_form_action
    output = make_remote_form
    assert_match(/\(this\.action/, output)
  end
end

class MakeDraggableTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  
  def setup
    initialize_test_request
  end
  
  def test_should_create_draggable_instance
    output = make_draggable
    assert_match(/new Draggable/, output)
  end
  
  def test_should_pass_this
    output = make_draggable
    assert_match(/\(this/, output)
  end
  
  def test_should_respond_to_options
    output = make_draggable( :revert => true )
    assert_match(/revert\:true/, output)
  end
end

class MakeDropRecievingTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  
  def setup
    initialize_test_request
  end
  
  def test_should_add_to_droppables
    output = make_drop_receiving
    assert_match(/Droppables\.add/, output)
  end
  
  def test_should_pass_this
    output = make_drop_receiving
    assert_match(/\(this/, output)
  end
  
  def test_should_generate_a_url_from_options
    output = make_drop_receiving( :url => { :action => "bingo" } )
    assert_match(/controller_stub\/bingo/, output)
  end
end

class MakeObservedTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  
  def setup
    initialize_test_request
  end
  
  def test_should_make_form_observer
    output = make_observed(:form)
    assert_match(/new Form\.EventObserver/, output)
  end
  
  def test_should_make_field_observer
    output = make_observed(:field)
    assert_match(/new Form\.Element\.EventObserver/, output)
  end
  
  def test_should_pass_this
    output = make_observed(:field)
    assert_match(/\(this/, output)
  end
  
  def test_should_make_a_timed_observer_if_frequency_passed
    output = make_observed(:form, :frequency => 3 )
    assert_match(/new Form.Observer/, output)
    assert_match(/3,/, output)
  end
  
  def test_should_generate_a_url_from_options
    output = make_observed(:field, :url => { :action => "bingo" } )
    assert_match(/controller_stub\/bingo/, output)
  end
  
  def test_should_respond_to_options
    output = make_observed(:field, :function => 'alert("boo")' )
    assert_match(/function\(element, value\) \{alert\("boo"\)\}/, output)
  end
end

