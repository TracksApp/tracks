require 'selenium_on_rails/test_builder_actions'
require 'selenium_on_rails/test_builder_accessors'

# Create test_builder_user_actions.rb to support actions included
# in selenium-core's user-extensions.js
#
# See test_builder_user_actions.rb.example for examples matching
# selenium-core's user-extensions.js.sample
module SeleniumOnRails::TestBuilderUserActions
end
require 'selenium_on_rails/test_builder_user_actions' if File.exist?(File.expand_path(File.join(File.dirname(__FILE__), 'test_builder_user_actions.rb')))


# Create test_builder_user_accessors.rb to support accessors
# included in selenium-core's user-extensions.js
#
# See test_builder_user_accessors.rb.example for examples matching
# selenium-core's user-extensions.js.sample
module SeleniumOnRails::TestBuilderUserAccessors
end
require 'selenium_on_rails/test_builder_user_accessors' if File.exist?(File.expand_path(File.join(File.dirname(__FILE__), 'test_builder_user_accessors.rb')))

# Builds Selenium test table using a high-level Ruby interface. Normally
# invoked through SeleniumOnRails::RSelenese.
#
# See SeleniumOnRails::TestBuilderActions for the available actions and
# SeleniumOnRails::TestBuilderAccessors for the available checks.
#
# For more information on the commands supported by TestBuilder, see the
# Selenium Commands Documentation at
# http://release.openqa.org/selenium-core/nightly/reference.html.
class SeleniumOnRails::TestBuilder
  include SeleniumOnRails::TestBuilderActions
  include SeleniumOnRails::TestBuilderAccessors
  include SeleniumOnRails::TestBuilderUserActions
  include SeleniumOnRails::TestBuilderUserAccessors

  # Convert _str_ to a Selenium command name.
  def self.selenize str
    str.camelize.gsub(/^[A-Z]/) {|s| s.downcase }
  end

  # Prepends _pattern_ with 'exact:' if it would be considered containing 
  # string-match pattern otherwise.
  def exactize pattern
    pattern.include?(':') ? "exact:#{pattern}" : pattern
  end

  # Create a new TestBuilder for _view_.
  def initialize view
    @view = view
    @output = ''
    @xml = Builder::XmlMarkup.new :indent => 2, :target => @output
  end

  # Add a new table of tests, and return the HTML.
  def table title
    @xml.table do
      @xml.tr do @xml.th(title, :colspan => 3) end
      yield self
    end
  end

  # Add a new test command using _cmd_, _target_ and _value_.
  def command cmd, target=nil, value=nil
    @xml.tr do
      _tdata cmd
      _tdata target
      _tdata value
    end
  end
  # :nodoc
  alias_method :command_verbatim, :command 

  # Same as _command_ but add _AndWait_ to the name of _cmd_.
  def command_and_wait cmd, target=nil, value=nil
    command_verbatim cmd.to_s + 'AndWait', target, value
  end

  # Re routes commands in the provided block to #command_and_wait instead of
  # #command.
  def make_command_waiting
    self.class.send :alias_method, :command, :command_and_wait
    yield
    self.class.send :alias_method, :command, :command_verbatim 
  end

protected

  # If _url_ is a string, return unchanged.  Otherwise, pass it to
  # ActionView#UrlHelper#url_for.
  def url_arg url
    if url.instance_of?(String) then url else exactize(@view.url_for(url)) end
  end

  # If _arg_ is an array formats _arg_ to a textual representation.
  # Otherwise return unchanged.
  def collection_arg arg
    if arg.is_a? Array
      arg.collect {|e| e.gsub(/[\\,]/) {|s| "\\#{s}" } }.join(',')
    else
      arg
    end
  end

private

  # Output a single TD element.
  def _tdata value
    if value
      @xml.td(value.to_s)
    else
      @xml.td do @xml.target! << '&nbsp;' end
    end
  end
end
