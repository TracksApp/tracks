require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TaggingTest < ActiveSupport::TestCase
  fixtures :taggings, :tags

  def test_removes_unused_tags
    tag = Tag.create!(:name => "hello")
    tagging = Tagging.create!(:tag => tag, :taggable_id => 1, :taggable_type => "Todo")
    
    assert_equal 1, Tagging.where("tag_id = ?", tag.id).count
    
    tagging.destroy
    
    assert_nil Tag.where(:name => "hello").first
  end
end
