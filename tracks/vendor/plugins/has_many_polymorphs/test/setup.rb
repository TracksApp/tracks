
# Setup integration system for the integration suite

Dir.chdir "#{File.dirname(__FILE__)}/integration/app/" do
  Dir.chdir "vendor/plugins" do
    system("rm has_many_polymorphs; ln -s ../../../../../ has_many_polymorphs")
  end
  system("rake db:create")
  system("rake db:migrate db:fixtures:load")
end
