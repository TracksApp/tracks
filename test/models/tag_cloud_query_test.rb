require 'test_helper'

class TagCloudQueryTest < ActiveSupport::TestCase

  fixtures :tags, :taggings, :users

  def user
    @user ||= User.find 1
  end

  def test_get_all_tags
    tags = Stats::TagCloudQuery.new(user).result
    assert_equal 2, tags.size
    tags.sort_by! {|t| t.id}
    tag = tags.first
    assert_equal 3, tag.count
    assert_equal "foo", tag.name

    tag = tags.last
    assert_equal 1, tag.count
    assert_equal "bar", tag.name
  end

  def test_get_subset_of_tags
    tags = Stats::TagCloudQuery.new(user, 1.week.ago).result

    assert_equal 1, tags.size
    assert_equal 2, tags.first.count
    assert_equal "foo", tags.first.name
  end
end
