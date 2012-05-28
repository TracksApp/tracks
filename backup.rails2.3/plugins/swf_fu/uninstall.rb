require "fileutils"

dest = File.dirname(__FILE__) + "/../../../public"
FileUtils.rm  "#{dest}/javascripts/swfobject.js" rescue puts "Warning: swfobject.js could not be deleted"
FileUtils.rm  "#{dest}/swfs/expressInstall.swf" rescue puts "Warning: expressInstall.swf could not be deleted"
Dir.rmdir "#{dest}/swfs/" rescue "don't worry if directory is not empty"