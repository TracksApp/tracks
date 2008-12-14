Dir[File.join(File.dirname(__FILE__), "functional/*.rb")].each{|filename|
  require filename
}