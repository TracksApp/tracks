require File.join(File.dirname(__FILE__), '../test_helper.rb')

class BundleFu::JSMinimizerTest < Test::Unit::TestCase
  def test_minimize_content__should_be_less
    test_content = File.read(public_file("javascripts/js_1.js"))
    content_size = test_content.length
    minimized_size = BundleFu::JSMinimizer.minimize_content(test_content).length
    
    assert(minimized_size > 0)
    assert(content_size > minimized_size)
  end
end
