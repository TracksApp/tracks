require File.dirname(__FILE__) + '/../test_helper'

class ContextTest < Test::Unit::TestCase
  fixtures :contexts

  def setup
    @agenda = contexts(:agenda)
    @email = contexts(:email)
  end

  def test_validate_presence_of_name
     @agenda.name = ""
     assert !@agenda.save
     assert_equal 1, @agenda.errors.count
     assert_equal "context must have a name", @agenda.errors.on(:name)
  end
     
  def test_validate_name_is_less_than_256
     @agenda.name = "a"*256
     assert !@agenda.save
     assert_equal 1, @agenda.errors.count
     assert_equal "context name must be less than 256 characters", @agenda.errors.on(:name)
   end
     
  def test_validate_name_is_unique
     newcontext = Context.new
     newcontext.name = contexts(:agenda).name
     assert !newcontext.save
     assert_equal 1, newcontext.errors.count
     assert_equal "already exists", newcontext.errors.on(:name)
  end
  
  def test_validate_name_does_not_contain_slash
     newcontext = Context.new
     newcontext.name = "phone/telegraph"
     assert !newcontext.save
     assert_equal 1, newcontext.errors.count
     assert_equal "cannot contain the slash ('/') character", newcontext.errors.on(:name)
  end
end
