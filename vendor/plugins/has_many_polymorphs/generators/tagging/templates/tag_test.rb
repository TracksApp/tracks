require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags, :taggings, <%= taggable_models[0..1].join(", ") -%>

  def test_to_s
    assert_equal "delicious sexy", <%= model_two -%>.find(2).tags.to_s
  end
  
end
