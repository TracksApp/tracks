%w{field form label link logging page select_option session}.each do |file|
  require File.dirname(__FILE__) + "/core/#{file}"
end