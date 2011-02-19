require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags

  # Replace this with your real tests.
  def test_find_or_create_with_single_word
    tag = Tag.find_or_create_by_name("test")
    assert !tag.new_record?
  end

  def test_find_or_create_with_space
    tag = Tag.find_or_create_by_name("test test")
    assert !tag.new_record?
  end

  def test_find_or_create_with_dot
    tag = Tag.find_or_create_by_name("a.b.c")
    assert !tag.new_record?
  end

  def test_find_or_create_with_number_as_string
    tag = Tag.find_or_create_by_name("12343")
    assert !tag.new_record?

    tag = Tag.find_or_create_by_name("8.1.2")
    assert !tag.new_record?
  end

end
