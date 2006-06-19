module Arts
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::JavaScriptHelper
    
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
    
  def assert_rjs(action, *args, &block)
    respond_to?("assert_rjs_#{action}") ?
      send("assert_rjs_#{action}", *args) :
      assert(lined_response.include?(create_generator.send(action, *args, &block)), 
         generic_error(action, args))
  end
  
  def assert_no_rjs(action, *args, &block)
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs(action, *args, &block) }
  end
  
  def assert_rjs_insert_html(*args)
    position = args.shift
    item_id = args.shift
    
    content = extract_matchable_content(args)
    
    unless content.blank?
      case content
        when Regexp
          assert_match Regexp.new("new Insertion\.#{position.to_s.camelize}(.*#{item_id}.*,.*#{content.source}.*);"),
                       @response.body
        when String
          assert lined_response.include?("new Insertion.#{position.to_s.camelize}(\"#{item_id}\", #{content});"),
                 "No insert_html call found for \n" +
                 "     position: '#{position}' id: '#{item_id}' \ncontent: \n" +
                 "#{content}\n" +
                 "in response:\n#{lined_response}"
        else
          raise "Invalid content type"
      end
    else
      assert_match Regexp.new("new Insertion\.#{position.to_s.camelize}(.*#{item_id}.*,.*?);"), 
                   @response.body
    end
  end
  
  def assert_rjs_replace_html(*args)
    div = args.shift
    content = extract_matchable_content(args)
       
    unless content.blank?
      case content
        when Regexp
          assert_match Regexp.new("Element.update(.*#{div}.*,.*#{content.source}.*);"),
                       @response.body
        when String
          assert lined_response.include?("Element.update(\"#{div}\", #{content});"), 
                 "No replace_html call found on div: '#{div}' and content: \n#{content}\n" +
                 "in response:\n#{lined_response}"
        else
          raise "Invalid content type"
      end
    else
      assert_match Regexp.new("Element.update(.*#{div}.*,.*?);"), @response.body
    end
  end
  
  def assert_rjs_replace(*args)
    div = args.shift
    content = extract_matchable_content(args)
    
    unless content.blank?
      case content
        when Regexp
          assert_match Regexp.new("Element.replace(.*#{div}.*,.*#{content.source}.*);"),
                       @response.body
        when String
          assert lined_response.include?("Element.replace(\"#{div}\", #{content});"), 
                 "No replace call found on div: '#{div}' and content: \n#{content}\n" +
                 "in response:\n#{lined_response}"
        else
          raise "Invalid content type"
      end
    else
      assert_match Regexp.new("Element.replace(.*#{div}.*,.*?);"), @response.body
    end
  end
  
  protected
  
  def lined_response
    @response.body.split("\n")
  end
  
  def create_generator
    block = Proc.new { |*args| yield *args if block_given? } 
    JavaScriptGenerator.new self, &block
  end
  
  def generic_error(action, args)
    "#{action} with args [#{args.join(" ")}] does not show up in response:\n#{lined_response}"
  end
  
  def extract_matchable_content(args)
    if args.size == 1 and args.first.is_a? Regexp
      return args.first
    else
      return create_generator.send(:arguments_for_call, args)
    end
  end
end
