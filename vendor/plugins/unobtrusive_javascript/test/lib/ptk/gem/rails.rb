# We require the initializer to setup the environment properly
unless defined?(Rails::Initializer)
  if File.directory?("#{RAILS_ROOT}/../../../rails")
    require "#{RAILS_ROOT}/../../../rails/railties/lib/initializer"
  else
    require     'rubygems'
    require_gem 'rails'
    require     'initializer'
  end
  Rails::Initializer.run(:set_load_path)
end

# We overwrite load_environment so we can have only one file
module Rails
  class Initializer
    def load_environment
    end
  end
end

# We overwrite the default log to be a directory up
module Rails
  class Configuration
    def default_log_path
      File.join(root_path, "#{environment}.log")
    end
  end
end

# We then load it manually
PTK::Configuration.load :environment