require File.dirname(__FILE__) + '/test_helper'

class LabelledFormBuilder < ActionView::Helpers::FormBuilder
  (field_helpers - %w(hidden_field)).each do |selector|
    src = <<-END_SRC
      def #{selector}(field, *args, &proc)
        "<label for='\#{field}'>\#{field.to_s.humanize}:</label> " + super + "<br/>"
      end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end
end

class FormHelperExtensionsTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include SimplyHelpful::RecordIdentificationHelper
  
  def setup
    @record = Post.new
    @controller = Class.new do
      attr_reader :url_for_options
      def url_for(options, *parameters_for_method_reference)
        @url_for_options = options
        @url_for_options || "http://www.example.com"
      end
    end
    @controller = @controller.new
  end
  
  def test_form_for_with_record_identification_with_new_record
    _erbout = ''
    form_for(@record, {:html => { :id => 'create-post' }}) {}
    
    expected = "<form action='#{posts_url}' class='new_post' id='create-post' method='post'></form>"
    assert_dom_equal expected, _erbout
  end
  def test_form_for_with_record_identification_with_custom_builder
    _erbout = ''
    form_for(@record, :builder => LabelledFormBuilder) do |f|
      _erbout.concat(f.text_field(:name))
    end
    
    expected = "<form action='#{posts_url}' class='new_post' id='new_post' method='post'>" +
      "<label for='name'>Name:</label>" +
      " <input type='text' size='30' name='post[name]' id='post_name' value='new post' /><br />" +
      "</form>"
    assert_dom_equal expected, _erbout    
  end
  
  def test_form_for_with_record_identification_without_html_options
    _erbout = ''
    form_for(@record) {}
    
    expected = "<form action='#{posts_url}' class='new_post' method='post' id='new_post'></form>"
    assert_dom_equal expected, _erbout
  end

  def test_form_for_with_record_identification_with_existing_record
    @record.save
    _erbout = ''
    form_for(@record) {}
    
    expected = "<form action='#{post_url(@record)}' class='edit_post' id='edit_post_1' method='post'><div style='margin:0;padding:0'><input name='_method' type='hidden' value='put' /></div></form>"
    assert_dom_equal expected, _erbout
  end

  def test_remote_form_for_with_record_identification_with_new_record
    _erbout = ''
    remote_form_for(@record, {:html => { :id => 'create-post' }}) {}
    
    expected = %(<form action='#{posts_url}' onsubmit="new Ajax.Request('#{posts_url}', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;" class='new_post' id='create-post' method='post'></form>)
    assert_dom_equal expected, _erbout
  end

  def test_remote_form_for_with_record_identification_without_html_options
    _erbout = ''
    remote_form_for(@record) {}
    
    expected = %(<form action='#{posts_url}' onsubmit="new Ajax.Request('#{posts_url}', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;" class='new_post' method='post' id='new_post'></form>)
    assert_dom_equal expected, _erbout
  end

  def test_remote_form_for_with_record_identification_with_existing_record
    @record.save
    _erbout = ''
    remote_form_for(@record) {}
    
    expected = %(<form action='#{post_url(@record)}' id='edit_post_1' method='post' onsubmit="new Ajax.Request('#{post_url(@record)}', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;" class='edit_post'><div style='margin:0;padding:0'><input name='_method' type='hidden' value='put' /></div></form>)
    assert_dom_equal expected, _erbout
  end
end