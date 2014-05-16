require 'test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags

  def test_find_or_create_with_single_word
    tag = Tag.where(:name => "test").first_or_create
    assert !tag.new_record?
  end

  def test_find_or_create_with_space
    tag = Tag.where(:name => "test test").first_or_create
    assert !tag.new_record?
  end

  def test_find_or_create_with_dot
    tag = Tag.where(:name => "a.b.c").first_or_create
    assert !tag.new_record?
  end

  def test_find_or_create_with_number_as_string
    tag = Tag.where(:name => "12343").first_or_create
    assert !tag.new_record?

    tag = Tag.where(:name => "8.1.2").first_or_create
    assert !tag.new_record?
  end
  
  def test_tag_name_always_lowercase
    tag = Tag.where(:name => "UPPER").first_or_create
    assert !tag.new_record?
    
    upper = Tag.where(:name => "upper").first
    assert_not_nil upper
    assert upper.name == "upper"
  end
  
  def test_tag_name_stripped_of_spaces
    tag = Tag.where(:name => "  strip spaces  ").first_or_create
    assert !tag.new_record?
    
    assert tag.name == "strip spaces"
  end

  def test_tag_label
    assert_equal 'one-two-three', Tag.new(:name => 'one two three').label
  end

  def test_tag_as_string
    tags = [Tag.new(:name => 'tag1'), Tag.new(:name => 'tag2')]
    assert_equal 'tag1, tag2', tags.join(', ')
  end

end
