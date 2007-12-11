
# Run tests against all Rails versions

VENDOR_DIR = File.expand_path("~/Desktop/projects/vendor/rails")

HERE = File.expand_path(File.dirname(__FILE__))

Dir["#{VENDOR_DIR}/*"].each do |dir|
  puts "\n\n**** #{dir} ****\n\n"
  Dir.chdir "#{HERE}/integration/app/vendor" do  
    system("rm rails; ln -s #{dir} rails")    
  end
  system("ruby #{HERE}/unit/polymorph_test.rb")
end

system("rm #{HERE}/integration/app/vendor; svn up #{HERE}/integration/app/vendor")
