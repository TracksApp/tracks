
require 'rubygems'
gem 'echoe', '>=2.2'
require 'echoe'
require 'lib/has_many_polymorphs/rake_task_redefine_task'

Echoe.new("has_many_polymorphs") do |p|  
  p.project = "fauna"
  p.summary = "An ActiveRecord plugin for self-referential and double-sided polymorphic associations."
  p.url = "http://blog.evanweaver.com/files/doc/fauna/has_many_polymorphs/"  
  p.docs_host = "blog.evanweaver.com:~/www/bax/public/files/doc/"  
  p.dependencies = ["activerecord"]
  p.rdoc_pattern = /polymorphs\/association|polymorphs\/class_methods|polymorphs\/reflection|polymorphs\/autoload|polymorphs\/configuration|README|CHANGELOG|TODO|LICENSE|templates\/migration\.rb|templates\/tag\.rb|templates\/tagging\.rb|templates\/tagging_extensions\.rb/    
  p.require_signed = true
end

desc 'Run the test suite.'
Rake::Task.redefine_task("test") do
   puts "Warning! Tests must be run with the plugin installed in a functioning Rails\nenvironment."
   system "ruby -Ibin:lib:test test/unit/polymorph_test.rb #{ENV['METHOD'] ? "--name=#{ENV['METHOD']}" : ""}"
end
