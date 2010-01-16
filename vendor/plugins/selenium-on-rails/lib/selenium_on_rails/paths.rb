require 'selenium_on_rails_config'

module SeleniumOnRails
  module Paths
    
    def selenium_path
      @@selenium_path ||= find_selenium_path
      @@selenium_path
    end
    
    def selenium_tests_path
      return SeleniumOnRailsConfig.get("selenium_tests_path") if SeleniumOnRailsConfig.get("selenium_tests_path")
      File.expand_path(File.join(RAILS_ROOT, 'test/selenium'))
    end
    
    def view_path view
      File.expand_path(File.dirname(__FILE__) + '/../views/' + view)
    end
  
    # Returns the path to the layout template. The path is relative in relation
    # to the app/views/ directory since Rails doesn't support absolute paths
    # to layout templates.
    def layout_path
      'layout.rhtml'
    end
    
    def fixtures_path
      return SeleniumOnRailsConfig.get("fixtures_path") if SeleniumOnRailsConfig.get("fixtures_path")
      File.expand_path File.join(RAILS_ROOT, 'test/fixtures')
    end
    
    def log_path log_file
      File.expand_path(File.dirname(__FILE__) + '/../../log/' + File.basename(log_file))
    end

    def skip_file? file
      file.split('/').each do |f|
        return true if f.upcase == 'CVS' or f.starts_with?('.') or f.ends_with?('~') or f.starts_with?('_')
      end
      false
    end
    
    private ###############################################

    def find_selenium_path
      sel_dirs = SeleniumOnRailsConfig.get :selenium_path do
        File.expand_path(File.dirname(__FILE__) + '/../../selenium-core')
      end

      sel_dirs.to_a.each do |seleniumdir|
        ['', 'core', 'selenium', 'javascript'].each do |subdir|
          path = File.join seleniumdir, subdir
          return path if File.exist?(File.join(path, 'TestRunner.html'))
        end
      end
      
      raise 'Could not find Selenium Core installation'
    end
       
  end
end
