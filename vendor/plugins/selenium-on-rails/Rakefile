require 'rake'
require 'rake/testtask'
require 'rdoc/rdoc'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the Selenium on Rails plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Test the Selenium on Rails plugin, and run the _authortest.rb files, too'
Rake::TestTask.new(:alltests) do |t|
  t.libs << 'lib'
  # note: Both pattern and test_files are used, so the list of test files is
  # the union of the two. 
  t.pattern = 'test/**/*_test.rb'
  t.test_files = FileList['test/**/*_authortest.rb']
  t.verbose = true
end

desc 'Generate documentation for the Selenium on Rails plugin.'
task :rdoc do
  rm_rf 'doc'
  RDoc::RDoc.new.document(%w(--line-numbers --inline-source --title SeleniumOnRails README CHANGELOG lib))
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/*_test.rb']
    t.rcov_opts = ['-x /site_ruby/ -x .*gems.* --rails']
  end
rescue LoadError #if rcov isn't available, ignore
end
