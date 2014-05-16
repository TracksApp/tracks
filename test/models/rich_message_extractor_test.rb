require 'date'
require 'active_support/core_ext/object/blank'
require_relative '../../app/services/rich_message_extractor.rb'

class RichMessageExtractorTest < Minitest::Test

  def test_message_with_all_options
    message = "ohai@some-context~this-project>131012<131014#tag1#tag2*"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "some-context", extractor.context
    assert_equal "this-project", extractor.project
    assert_equal Time.zone.parse("2013-10-12").utc.to_s, extractor.show_from.utc.to_s
    assert_equal Time.zone.parse("2013-10-14").utc.to_s, extractor.due.utc.to_s
    assert_equal ["tag1","tag2"], extractor.tags
    assert extractor.starred?
  end

  def test_message_without_project
    message = "ohai @ some-context"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "some-context", extractor.context
    assert_equal nil, extractor.project
  end

  def test_message_without_context
    message = " ohai ~ some-project"
    extractor = RichMessageExtractor.new(message)
    assert_equal "ohai", extractor.description
    assert_equal "", extractor.context
    assert_equal "some-project", extractor.project
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

  def test_message_with_tags
    message = "some tags#tag 1#tag2"
    extractor = RichMessageExtractor.new(message)
    assert_equal ["tag 1","tag2"], extractor.tags
  end

  def test_message_with_no_tags
    message = "no tags"
    extractor = RichMessageExtractor.new(message)
    assert_equal nil, extractor.tags
  end

  def test_message_with_due_date
    message = "datetest<141013"
    extractor = RichMessageExtractor.new(message)
    assert_equal Time.zone.parse("2014-10-13").utc.to_s, extractor.due.utc.to_s
  end

  def test_message_with_no_due_date
    message = "no date"
    extractor = RichMessageExtractor.new(message)
    assert_equal nil, extractor.due
  end

  def test_message_with_show_from
    message = "datetest>161013"
    extractor = RichMessageExtractor.new(message)
    assert_equal Time.zone.parse("2016-10-13").utc.to_s, extractor.show_from.utc.to_s
  end

  def test_message_with_no_show_from
    message = "no tickler"
    extractor = RichMessageExtractor.new(message)
    assert_equal nil, extractor.show_from
  end

  def test_message_with_star
    message = "star test*"
    extractor = RichMessageExtractor.new(message)
    assert extractor.starred?
  end

  def test_message_with_no_star
    message = "no star test"
    extractor = RichMessageExtractor.new(message)
    refute extractor.starred?
  end

end
