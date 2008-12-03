# load all files
for file in ["/lib/bundle_fu.rb", "/lib/bundle_fu/js_minimizer.rb", "/lib/bundle_fu/css_url_rewriter.rb", "/lib/bundle_fu/file_list.rb"]
  require File.expand_path(File.join(File.dirname(__FILE__), file))
end
