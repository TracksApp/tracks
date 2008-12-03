require File.join(File.dirname(__FILE__), '../test_helper.rb')

class CSSBundleTest < Test::Unit::TestCase
  def test__rewrite_relative_path__should_rewrite
    assert_rewrites("/stylesheets/active_scaffold/default/stylesheet.css", 
      "../../../images/spinner.gif" => "/images/spinner.gif",
      "../../../images/./../images/goober/../spinner.gif" => "/images/spinner.gif"
    )
    
    assert_rewrites("stylesheets/active_scaffold/default/./stylesheet.css", 
      "../../../images/spinner.gif" => "/images/spinner.gif")
      
    assert_rewrites("stylesheets/main.css", 
      "image.gif" => "/stylesheets/image.gif")
      
    assert_rewrites("/stylesheets////default/main.css", 
      "..//image.gif" => "/stylesheets/image.gif")
      
    assert_rewrites("/stylesheets/default/main.css", 
      "/images/image.gif" => "/images/image.gif")
  end
  
  def test__rewrite_relative_path__should_strip_spaces_and_quotes
    assert_rewrites("stylesheets/main.css", 
      "'image.gif'" => "/stylesheets/image.gif",
      " image.gif " => "/stylesheets/image.gif"
    )
  end
  
  def test__rewrite_relative_path__shouldnt_rewrite_if_absolute_url
    assert_rewrites("stylesheets/main.css", 
      " 'http://www.url.com/images/image.gif' " => "http://www.url.com/images/image.gif",
      "http://www.url.com/images/image.gif" => "http://www.url.com/images/image.gif",
      "ftp://www.url.com/images/image.gif" => "ftp://www.url.com/images/image.gif"
    )
  end
  
  def test__bundle_css_file__should_rewrite_relatiave_path
    bundled_css = BundleFu.bundle_css_files(["/stylesheets/css_3.css"])
    assert_match("background-image: url(/images/background.gif)", bundled_css)
    assert_match("background-image: url(/images/groovy/background_2.gif)", bundled_css)
  end
  
  def test__bundle_css_files__no_images__should_return_content
    bundled_css = BundleFu.bundle_css_files(["/stylesheets/css_1.css"])
    assert_match("css_1 { }", bundled_css)
  end
  
  
  def assert_rewrites(source_filename, rewrite_map)
    rewrite_map.each_pair{|source, dest|
      assert_equal(dest, BundleFu::CSSUrlRewriter.rewrite_relative_path(source_filename, source))
    }
  end
end
