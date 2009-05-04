# Let's make sure everyone else is loaded
require File.expand_path(RAILS_ROOT + "/config/environment")
require 'spec'
require 'spec/rails'
begin
  require 'ruby2ruby'
rescue LoadError
  puts "-----"
  puts "Attention: skinny_spec requires ruby2ruby for nicer route descriptions"
  puts "It is highly recommended that you install it: sudo gem install ruby2ruby"
  puts "-----"
end

# Let's load our family now
require "lucky_sneaks/common_spec_helpers"
require "lucky_sneaks/controller_request_helpers"
require "lucky_sneaks/controller_spec_helpers"
require "lucky_sneaks/controller_stub_helpers"
require "lucky_sneaks/model_spec_helpers"
require "lucky_sneaks/view_spec_helpers"

# Let's all come together
Spec::Rails::Example::ViewExampleGroup.send :include, LuckySneaks::ViewSpecHelpers
Spec::Rails::Example::HelperExampleGroup.send :include, LuckySneaks::CommonSpecHelpers
Spec::Rails::Example::ControllerExampleGroup.send :include, LuckySneaks::ControllerSpecHelpers
Spec::Rails::Example::ModelExampleGroup.send :include, LuckySneaks::ModelSpecHelpers