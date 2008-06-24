require File.expand_path(File.dirname(__FILE__) + '/testing/plugit_descriptor')

require 'rake/rdoctask'
Rake::RDocTask.new(:doc) do |r|
  r.title = "Rails Scenarios Plugin"
  r.main = "README"
  r.options << "--line-numbers"
  r.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  r.rdoc_dir = "doc"
end