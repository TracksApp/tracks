require 'singleton'

module PTK

  class Configuration
    class << self
      def load(config, fatal = false)
        if (file = PTK::PathSet.instance.send(config)) == :ignore then false
        elsif File.exists?(file)
          require file
          true
        elsif fatal then raise LoadError, "PTK could not find #{file}"
        else
          STDERR.puts "PTK::WARNING: could not find #{file}"
          false
        end
      end
      
      def find_path(config, fatal = false)
        if (file = PTK::PathSet.instance.send(config)) == :ignore then false
        elsif File.exists?(file) then file
        elsif fatal then raise LoadError, "PTK could not find #{file}"
        else
          STDERR.puts "PTK::WARNING: could not find #{file}"
          false
        end
      end

      def draw
        yield PTK::PathSet.instance
      end
    end
  end

  class PathSet
    include Singleton

    attr_accessor :ptk_prefix
    attr_accessor :config
    attr_accessor :fixtures
    attr_accessor :environment
    attr_accessor :schema
    attr_accessor :database
    attr_accessor :routes

    def initialize
      self.ptk_prefix = 'ptk'
      self.config = File.join(RAILS_ROOT, 'config')
      self.fixtures = File.join(RAILS_ROOT, 'fixtures')
      
      self.environment = File.join(self.config, 'environment.rb')

      self.database = File.join(self.config, 'database.yml')
      self.schema = File.join(self.config, 'schema.rb')
      
      self.routes = File.join(self.config, 'routes.rb')
    end
  end
  
  class Initializer

    # The init.rb in the root directory of the plugin will be loaded by default
    attr_accessor :init

    # The specific environmental frameworks of a plugin, such as needing the ActionController
    # ActionMailer or ActiveRecord gems to be preloaded. A special requirement called
    # 'environment' will load tests as though they were in the test environment of a normal
    # Rails application.
    attr_accessor :frameworks
    def frameworks
      [@frameworks].flatten
    end

    # Suites are test extensions including assertions and various tools for easier testing
    attr_accessor :suites
    def suites
      [@suites].flatten
    end

    # A container for the PathSet instance
    attr_reader :paths
    
    def initialize
      self.init         = true
      self.frameworks   = :none
      self.suites       = :all
      @paths            = PTK::PathSet.instance
    end

    def self.run(command = :process)
      initializer = PTK::Initializer.new
      yield initializer if block_given?
      initializer.send(command)
    end
    
    def process
      initialize_frameworks
      initialize_suites
      initialize_plugin
    end
    
    def initialize_frameworks
      return if frameworks.include?(:none)
      self.frameworks = [:rails] if frameworks.include?(:rails)
      frameworks.each { |lib| require_ptk File.join('gem', lib.to_s) }
    end
    
    def initialize_suites
      return if suites.include?(:none)
      self.suites = all_suites if suites.include?(:all)
      suites.each { |lib| require_ptk File.join('suite', lib.to_s) }
    end
    
    def initialize_plugin
      return unless self.init
      require File.join(RAILS_ROOT, '..', 'init')
    end

    protected

    def all_suites
      Dir.glob(File.join(RAILS_ROOT, 'lib', 'ptk', 'suite', '*.rb')).inject([]) do |a, file|
        a << File.basename(file, '.rb').to_sym
        a
      end
    end

    def require_ptk(library)
      file = paths.ptk_prefix.empty? ? library : File.join(paths.ptk_prefix, library)
      require file
    end
    
  end
  
  class LoadPath

    def self.expand(file, *dirs)
      File.join(*([File.expand_path(File.dirname(file))] << dirs))
    end

    def self.add(*dirs)
      path = File.expand_path(File.join(*dirs))
      $:.unshift path
      $:.uniq!
    end

  end
end