require 'fileutils'

flashobject = File.dirname(__FILE__) + '/../../../public/javascripts/flashobject.js'
FileUtils.cp File.dirname(__FILE__) + '/javascripts/flashobject.js', flashobject unless File.exist?(flashobject)
puts IO.read(File.join(File.dirname(__FILE__), 'README'))