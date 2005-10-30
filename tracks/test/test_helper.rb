ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
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