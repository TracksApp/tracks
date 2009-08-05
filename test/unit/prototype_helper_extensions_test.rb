require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/prototype_helper_extensions'

class PrototypeHelperExtensionsTest < ActiveSupport::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::ScriptaculousHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper

  def setup
    @template = nil
    @controller = Class.new do
      def url_for(options, *parameters_for_method_reference)
        if options.is_a?(String)
          options
        elsif options.is_a?(Hash)
          url =  "http://www.example.com/"
          url << options[:action].to_s if options and options[:action]
          url << "?a=#{options[:a]}" if options && options[:a]
          url << "&b=#{options[:b]}" if options && options[:a] && options[:b]
          url
        elsif options.is_a?(JavaScriptRef)
          url = options.to_json
        else
          raise 'unhandled type' + options.class.inspect
        end
      end

    end.new
    @generator = create_generator
  end
  
  def test_confirming
    @generator.confirming("Please confirm.") do
      @generator.alert 'foo'
    end
    assert_equal "if (confirm('Please confirm.')) {\nalert(\"foo\");\n}", @generator.to_s
  end
  
  def test_confirming_with_javascript
    @generator.confirming("'Please confirm ' + this.title + '.'") do
      @generator.alert 'foo'
    end
    assert_equal "if (confirm('Please confirm ' + this.title + '.')) {\nalert(\"foo\");\n}", @generator.to_s
  end
  
  def test_remote_to_href
    assert_equal "new Ajax.Request(this.href, {asynchronous:true, evalScripts:true})\n", remote_to_href
  end

  def test_remote_to_href_with_options
    assert_equal "new Ajax.Request(this.href, {asynchronous:true, evalScripts:true, method:'put'})\n", remote_to_href(:method => 'put')
  end
       
  protected
    def create_generator
      block = Proc.new { |*args| yield *args if block_given? }
      JavaScriptGenerator.new self, &block
    end
    
    def protect_against_forgery?
      false
    end
    
    attr_accessor :output_buffer        
end

