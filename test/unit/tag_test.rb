require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TagTest < ActiveSupport::TestCase
  fixtures :tags

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
  
  def test_tag_name_always_lowercase
    tag = Tag.find_or_create_by_name("UPPER")
    assert !tag.new_record?
    
    upper = Tag.find_by_name("UPPER")
    assert_not_nil upper
    assert upper.name == "upper"
  end
  
  def test_tag_name_stripped_of_spaces
    tag = Tag.find_or_create_by_name("  strip spaces  ")
    assert !tag.new_record?
    
    assert tag.name == "strip spaces"
  end
  
end
