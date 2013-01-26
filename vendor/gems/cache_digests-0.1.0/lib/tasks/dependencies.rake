namespace :cache_digests do
  desc 'Lookup nested dependencies for TEMPLATE (like messages/show or comments/_comment.html)'
  task :nested_dependencies => :environment do
    template, format = ENV['TEMPLATE'].split(".")
    format ||= :html
    puts JSON.pretty_generate CacheDigests::TemplateDigestor.new(template, format, ApplicationController.new.lookup_context).nested_dependencies
  end

  desc 'Lookup first-level dependencies for TEMPLATE (like messages/show or comments/_comment.html)'
  task :dependencies => :environment do
    template, format = ENV['TEMPLATE'].split(".")
    format ||= :html
    puts JSON.pretty_generate CacheDigests::TemplateDigestor.new(template, format, ApplicationController.new.lookup_context).dependencies
  end
end