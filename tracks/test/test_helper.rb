ENV["RAILS_ENV"] = "test"

# Expand the path to environment so that Ruby does not load it multiple times
# File.expand_path can be removed if Ruby 1.9 is in use.
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'application'

require 'test/unit'
require 'active_record/fixtures'
require 'action_controller/test_process'
require 'action_web_service/test_invoke'
require 'breakpoint'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

class Test::Unit::TestCase
  # Turn these on to use transactional fixtures with table_name(:fixture_name) instantiation of fixtures
  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures  = false

  def create_fixtures(*table_names)
    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures", table_names)
  end

  # Logs in a user and returns the user object found in the session object
  #
  def login(login,password)
    post :login, {:user_login => login, :user_password => password}
    assert_not_nil(session['user'])
    return User.find(session['user'].id)
  end
  
  # Generates a random string of ascii characters (a-z, "1 0")
  # of a given length for testing assignment to fields
  # for validation purposes
  #
  def generate_random_string(length)
    string = ""
    characters = %w(a b c d e f g h i j k l m n o p q r s t u v w z y z 1\ 0)
    length.times do
      pick = characters[rand(26)]
      string << pick
    end
    return string
  end
  
end