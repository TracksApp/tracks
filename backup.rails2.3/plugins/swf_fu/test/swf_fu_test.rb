require File.expand_path(File.dirname(__FILE__)+'/test_helper')
require File.expand_path(File.dirname(__FILE__)+'/results')

class SwfFuTest < ActionView::TestCase
  def assert_same_stripped(expect, test)
    expect, test = [expect, test].map{|s| s.split("\n").map(&:strip)}
    same = expect & test
    delta_expect, delta_test = [expect, test].map{|a| a-same}
    STDOUT << "\n\n---- Actual result: ----\n" << test.join("\n") << "\n---------\n" unless delta_expect == delta_test
    assert_equal delta_expect, delta_test
  end

  context "swf_path" do
    context "with no special asset host" do
      should "deduce the extension" do
        assert_equal swf_path("example.swf"), swf_path("example")
        assert_starts_with "/swfs/example.swf", swf_path("example.swf")
      end

      should "accept relative paths" do
        assert_starts_with "/swfs/whatever/example.swf", swf_path("whatever/example.swf")
      end

      should "leave full paths alone" do
        ["/full/path.swf", "http://www.example.com/whatever.swf"].each do |p|
          assert_starts_with p, swf_path(p)
        end
      end
    end

    context "with custom asset host" do
      HOST = "http://assets.example.com"
      setup do
        ActionController::Base.asset_host = HOST
      end

      teardown do
        ActionController::Base.asset_host = nil
      end

      should "take it into account" do
        assert_equal "#{HOST}/swfs/whatever.swf", swf_path("whatever")
      end
    end
  end

  context "swf_tag" do
    COMPLEX_OPTIONS = { :width => "456", :height => 123,
                        :flashvars => {:myVar => "value 1 > 2"}.freeze,
                        :javascript_class => "SomeClass",
                        :initialize => {:be => "good"}.freeze,
                        :parameters => {:play => true}.freeze
                      }.freeze

    should "understand size" do
      assert_equal  swf_tag("hello", :size => "123x456"),
                    swf_tag("hello", :width => 123, :height => "456")
    end

    should "only accept valid modes" do
      assert_raise(ArgumentError) { swf_tag("xyz", :mode => :xyz)  }
    end

    context "with custom defaults" do
      setup do
        test = {:flashvars=> {:xyz => "abc", :hello => "world"}.freeze, :mode => :static, :size => "400x300"}.freeze
        @expect = swf_tag("test", test)
        @expect_with_hello = swf_tag("test", :flashvars => {:xyz => "abc", :hello => "my friend"}, :mode => :static, :size => "400x300")
        ActionView::Base.swf_default_options = test
      end

      should "respect them" do
        assert_equal @expect, swf_tag("test")
      end

      should "merge suboptions" do
        assert_equal @expect_with_hello, swf_tag("test", :flashvars => {:hello => "my friend"}.freeze)
      end

      teardown { ActionView::Base.swf_default_options = {} }
    end

    context "with proc options" do
      should "call them" do
        expect = swf_tag("test", :id => "generated_id_for_test")
        assert_equal expect, swf_tag("test", :id => Proc.new{|arg| "generated_id_for_#{arg}"})
      end

      should "call global default's everytime" do
        expect1 = swf_tag("test", :id => "call_number_1")
        expect2 = swf_tag("test", :id => "call_number_2")
        cnt = 0
        ActionView::Base.swf_default_options = { :id => Proc.new{ "call_number_#{cnt+=1}" }}
        assert_equal expect1, swf_tag("test")
        assert_equal expect2, swf_tag("test")
      end
    end

    context "with static mode" do
      setup { ActionView::Base.swf_default_options = {:mode => :static} }

      should "deal with string flashvars" do
        assert_equal  swf_tag("hello", :flashvars => "xyz=abc", :mode => :static),
                      swf_tag("hello", :flashvars => {:xyz => "abc"}, :mode => :static)
      end

      should "produce the expected code" do
        assert_same_stripped STATIC_RESULT, swf_tag("mySwf", COMPLEX_OPTIONS.merge(:html_options => {:class => "lots"}.freeze).freeze)
      end

      teardown { ActionView::Base.swf_default_options = {} }
    end

    context "with dynamic mode" do
      should "produce the expected code" do
        assert_same_stripped DYNAMIC_RESULT, swf_tag("mySwf", COMPLEX_OPTIONS)
      end

    end

    should "enforce HTML id validity" do
      div_result = '<div id="swf_123-456_ok___X_div">'
      assert_match /#{div_result}/, swf_tag("123-456_ok$!+X")
      obj_result = '"id":"swf_123-456_ok___X"'
      assert_match /#{obj_result}/, swf_tag("123-456_ok$!+X")
    end

    should "treat initialize arrays as list of parameters" do
      assert_match 'initialize("hello","world")', swf_tag("mySwf", :initialize => ["hello", "world"], :javascript_class => "SomeClass")
    end

    if ActiveSupport.const_defined?(:SafeBuffer)
      should "be html safe" do
        assert swf_tag("test").html_safe?
      end
    end
  end

  context "flashobject_tag" do
    should "be the same as swf_tag with different defaults" do
      assert_same_stripped swf_tag("mySwf",
        :auto_install     => nil,
        :parameters       => {:scale => "noscale", :bgcolor => "#ffffff"},
        :flashvars        => {:lzproxied => false},
        :id               => "myFlash"
      ), flashobject_tag("mySwf", :flash_id => "myFlash")
    end

    should "be the same with custom settings" do
      assert_same_stripped swf_tag("mySwf",
        :auto_install     => nil,
        :parameters       => {:scale => "noborder", :bgcolor => "#ffffff"},
        :flashvars        => {:answer_is => 42},
        :id               => "myFlash"
      ), flashobject_tag("mySwf", :flash_id => "myFlash", :parameters => {:scale => "noborder"}, :variables => {:answer_is => 42})
    end
  end
end

