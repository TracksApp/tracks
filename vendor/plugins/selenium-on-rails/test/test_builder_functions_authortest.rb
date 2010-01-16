#----------------------------------------------------------------------------
# This is a *_authortest.rb file, which means it will only run if you run:
# rake alltests
# It is not run as part of the standard test suite, as it's of limited
# value unless you're actually developing Selenium On Rails.

#----------------------------------------------------------------------------
# The test_builder_actions.rb and test_builder_accessors.rb files do not
# necessarily contain all the functions which are available in Selenium.
# Here we use the iedoc.xml file to find functions which might need to be
# added to the files.  Ultimately it would be great not to need to do this
# process manually, however, this is a temporary step toward improving
# function parity.

require File.dirname(__FILE__) + '/test_helper'

class TestTheTestBuilderFunctions < Test::Unit::TestCase

  def test_functions_in_iedoc_are_supported

    base_path = File.dirname(__FILE__) + '/../'

    iedoc_file = File.read base_path + "selenium-core/iedoc.xml"
    test_builder_actions_file = File.read base_path + "lib/selenium_on_rails/test_builder_actions.rb"
    test_builder_accessors_file = File.read base_path + "lib/selenium_on_rails/test_builder_accessors.rb"

    # Don't include any deprecated functions
    deprecated_functions = %W{dragdrop}

    iedoc_functions = iedoc_file.scan(/function *name *= *["']([a-zA-Z]+)["']/)\
                                .sort.collect{|x| x[0]} - deprecated_functions

    for function_name in iedoc_functions

      function_name.gsub!(/[A-Z]/) { |s| "_" + s.downcase }
      
      test_description = "The function listed in the iedoc.xml file, " +
                         "#{function_name}, exists in the test_builder files" 
      
      if test_builder_actions_file.match(/def *#{function_name}/) ||
          test_builder_accessors_file.match(/(?:def *|tt>)#{function_name}/)
        assert true, test_description
      else
        assert false, test_description
      end
    end
    
  end
  
end

