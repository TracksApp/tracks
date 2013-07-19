require 'test/unit'
require 'active_support/core_ext/object/blank'
require_relative '../../app/services/rich_message_extractor.rb'

class RichMessageExtractorTest < Test::Unit::TestCase

  def test_message_with_all_options
    message = "ohai@some-context>in-this-project"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "some-context", extractor.context
    assert_equal "in-this-project", extractor.project
  end

  def test_message_without_project
    message = "ohai @ some-context"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "some-context", extractor.context
    assert_equal nil, extractor.project
  end

  def test_message_without_project
    message = " ohai @ some-context"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "some-context", extractor.context
    assert_equal nil, extractor.project
  end

  def test_message_without_project_or_context
    message = "ohai"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "", extractor.context
    assert_equal nil, extractor.project
  end

  def test_message_without_anything
    message = ""
    extractor = RichMessageExtractor.new(message)
    assert_equal "", extractor.description
    assert_equal "", extractor.context
    assert_equal nil, extractor.project
  end

  def test_message_with_just_a_context
    message = "@some-context"
    extractor = RichMessageExtractor.new(message)
    assert_equal "", extractor.description
    assert_equal "some-context", extractor.context
    assert_equal nil, extractor.project
  end

end
