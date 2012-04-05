require "fileutils"

# Some paths
src = File.dirname(__FILE__)+"/assets"
dest = File.dirname(__FILE__)+"/../../../public"

filename =  "#{dest}/javascripts/swfobject.js"
unless File.exist?(filename)
  FileUtils.cp "#{src}/javascripts/swfobject.js", filename
  puts "Copying 'swfobject.js'"
end

unless File.exist?("#{dest}/swfs/")
  FileUtils.mkdir "#{dest}/swfs/" 
  puts "Creating new 'swfs' directory for swf assets"
end

filename = "#{dest}/swfs/expressInstall.swf"
unless File.exist?(filename)
  FileUtils.cp "#{src}/swfs/expressInstall.swf", filename
  puts "Copying 'expressInstall.swf', the default flash auto-installer."
end

puts "Installation done."
