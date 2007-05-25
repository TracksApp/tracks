require 'rubygems'
require 'rake'
require 'lib/has_many_polymorphs/rake_task_redefine_task'

NAME = "has_many_polymorphs"

begin
  require 'rake/clean'
  gem 'echoe', '>= 1.1'
  require 'echoe'
  require 'fileutils'

  AUTHOR = "Evan Weaver"
  EMAIL = "evan at cloudbur dot st"
  DESCRIPTION = "Self-referential, polymorphic has_many :through helper for ActiveRecord."
  CHANGES = `cat README`[/^([\d\.]+\. .*)/, 1]
  RUBYFORGE_NAME = "polymorphs"
  GEM_NAME = "has_many_polymorphs" 
  HOMEPATH = "http://blog.evanweaver.com"
  RELEASE_TYPES = ["gem"]
  REV = nil
  VERS = `cat README`[/^([\d\.]+)\. /, 1]
  CLEAN.include ['**/.*.sw?', '*.gem', '.config']
  RDOC_OPTS = ['--quiet', '--title', "has_many_polymorphs documentation",
      "--opname", "index.html",
      "--line-numbers", 
      "--main", "README",
      "--inline-source"]
  
  include FileUtils
    
  echoe = Echoe.new(GEM_NAME, VERS) do |p|
    p.author = AUTHOR 
    p.rubyforge_name = RUBYFORGE_NAME
    p.name = NAME
    p.description = DESCRIPTION
    p.changes = CHANGES
    p.email = EMAIL
    p.summary = DESCRIPTION
    p.url = HOMEPATH
    p.need_tar = false
    p.need_tar_gz = true
    p.test_globs = ["*_test.rb"]
    p.clean_globs = CLEAN  
  end
            
rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."
  
  desc 'Run the default tasks'
  task :default => :test
end

desc 'Run the test suite.'
Rake::Task.redefine_task("test") do
   puts "Notice; tests must be run from within a functioning Rails environment."
   system "ruby -Ibin:lib:test test/unit/polymorph_test.rb #{ENV['METHOD'] ? "--name=#{ENV['METHOD']}" : ""}"
end
