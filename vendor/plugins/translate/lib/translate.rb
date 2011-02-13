module Translate
end

require File.join(File.dirname(__FILE__), "translate_controller")
require File.join(File.dirname(__FILE__), "translate_helper")
Dir[File.join(File.dirname(__FILE__), "translate", "*.rb")].each do |file|
  require file
end
