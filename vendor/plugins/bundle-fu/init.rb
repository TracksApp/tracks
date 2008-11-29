# EZ Bundle
for file in ["/lib/bundle_fu.rb", "/lib/js_minimizer.rb", "/lib/bundle_fu/file_list.rb"]
end
require File.expand_path(File.join(File.dirname(__FILE__), "environment.rb"))

ActionView::Base.send(:include, BundleFu::InstanceMethods)