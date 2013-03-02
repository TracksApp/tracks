require File.expand_path(File.dirname(__FILE__) + '/../minimal_test_helper')
require 'app/models/stats/tag_cloud'

class TagCloudTest < Test::Unit::TestCase

  FakeTag = Struct.new(:name, :count)

  def test_tags_get_sorted_alphabetically
    tags = [FakeTag.new("bee", 1), FakeTag.new("See", 10), FakeTag.new("aye", 100)]

    assert_equal %w(aye bee See), Stats::TagCloud.new(tags).tags.map(&:name)
  end

  def test_tag_relative_size
    tags = [FakeTag.new("bee", 1), FakeTag.new("See", 10), FakeTag.new("aye", 100)]
    cloud = Stats::TagCloud.new(tags)

    assert_equal 0, cloud.relative_size(FakeTag.new("whatever", 1))
    assert_equal 4, cloud.relative_size(FakeTag.new("whatever", 50))
    assert_equal 9, cloud.relative_size(FakeTag.new("whatever", 100))
  end

end
