require File.dirname(__FILE__) + '/test_helper'
require 'asset_tag_helper_patches'

class JavascriptIncludeTagWithUnobtrusiveOption < Test::Unit::TestCase
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  
  def setup
    initialize_test_request
    @output = javascript_include_tag(:unobtrusive).split("\n")
  end
  
  def test_should_render_script_tag_for_lowpro
    assert @output.include?('<script src="/javascripts/lowpro.js?" type="text/javascript"></script>')
  end
  
  def test_should_render_script_tag_for_current_requests_behaviour
    assert @output.include?('<script src="/behaviours/controller_stub.js?" type="text/javascript"></script>')
  end
  
  def test_should_render_index_behaviour_when_request_path_is_just_a_forward_slash
    @controller.request.stubs(:path).returns('/')
    @output = javascript_include_tag(:unobtrusive).split("\n")
    assert @output.include?('<script src="/behaviours/index.js?" type="text/javascript"></script>')
  end
  
  def test_should_render_index_behaviour_when_request_path_is_blank_as_a_result_of_a_url_prefix
    @controller.request.stubs(:path).returns('')
    @output = javascript_include_tag(:unobtrusive).split("\n")
    assert @output.include?('<script src="/behaviours/index.js?" type="text/javascript"></script>')
  end
end