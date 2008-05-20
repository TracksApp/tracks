module SeleniumOnRails
  module Paths
    def selenium_path
      @@selenium_path ||= find_selenium_path
      @@selenium_path
    end
    
    def selenium_tests_path
      File.expand_path(File.join(RAILS_ROOT, 'test/selenium'))
    end
    
    def view_path view
      File.expand_path(File.dirname(__FILE__) + '/../views/' + view)
    end
  
    # Returns the path to the layout template. The path is relative in relation
    # to the app/views/ directory since Rails doesn't support absolute paths
    # to layout templates.
    def layout_path
      rails_root = Pathname.new File.expand_path(File.join(RAILS_ROOT, 'app/views'))
      view_path = Pathname.new view_path('layout')
      view_path.relative_path_from(rails_root).to_s
    end
    
    def fixtures_path
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
    
    private
      def find_selenium_path
        sel_dirs = SeleniumOnRailsConfig.get :selenium_path do
          ds = [File.expand_path(File.join(RAILS_ROOT, 'vendor/selenium')),
                File.expand_path(File.join(RAILS_ROOT, 'vendor/selenium-core'))]
          gems = Gem.source_index.find_name 'selenium', nil
          ds << gems.last.full_gem_path unless gems.empty?
          ds
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
