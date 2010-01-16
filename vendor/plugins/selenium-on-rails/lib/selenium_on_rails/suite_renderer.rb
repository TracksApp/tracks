require 'selenium_on_rails'

module SeleniumOnRails
  module SuiteRenderer
    def test_suite_name path
      return 'All test cases' if [nil, '/'].include? path_to_relative_url(path)
      File.split(path)[-1].humanize
    end
  
    def test_suites path
      suites = []

      parent_path = File.join(File.split(path).slice(0..-2)) #all but last
      parent_path = path_to_relative_url parent_path
      suites << ['..', parent_path] unless parent_path.nil?

      visit_all_tests path, '', Proc.new {|n, p| suites << [n,path_to_relative_url(p)]}, nil
      suites
    end

    def test_cases path
      tests = []
      visit_all_tests path, '', nil, Proc.new {|n, p| tests << [n,p]}
      tests
    end
  
    def link_to_test_case suite_name, filename
      name = suite_name + test_case_name(filename)
      link_to name, :action => :test_file, :testname => path_to_relative_url(filename).sub(/^\//,'')
    end
  
    private ###############################################
    
    def path_to_relative_url path
      slt = @controller.selenium_tests_path
      return nil unless path.index slt
      path.sub slt, ''
    end
            
    def visit_all_tests path, suite_name, suite_consumer, test_consumer
      dirs = [] #add dirs to an array in order for files to be processed before dirs
      Dir.entries(path).sort.each do |e|
        next if skip_file?(e) or ['.','..'].include?(e)
        filename = File.join path, e
        if File.directory? filename
          dirs << [filename, "#{suite_name}#{e.humanize}."]
          suite_consumer.call("#{suite_name}#{e.humanize}", filename) if suite_consumer
        else
          test_consumer.call(suite_name, filename) if test_consumer
        end
      end
      #recurse through dirs
      dirs.each {|p, n| visit_all_tests p, n, suite_consumer, test_consumer }
    end      
  end
end
