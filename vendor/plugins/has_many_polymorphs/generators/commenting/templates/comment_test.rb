require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :commentings, <%= commentable_models[0..1].join(", ") -%>

  def test_to_s
    assert_equal "no1@nowhere.com", <%= model_two -%>.find(2).comments.first.email
    assert_equal "http://letrails.cn", <%= model_two -%>.find(2).comments.last.url
    assert_equal "http://fr.ivolo.us", <%= model_two -%>.find(2).comments.first.url
  end
  
end
