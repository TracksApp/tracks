task :rewrite_locales_utf8 do
  require 'base64'
  Dir[Rails.root.join("config/locales/*.yml")].each do |path|
    content = File.read(path)
    content.force_encoding('utf-8')
    content.gsub! /\\x([A-Fa-f0-9]{2})/ do |hex|
      Integer(hex[2..3], 16).chr
    end
    content.gsub! /!binary \|\n\s+(.+?)\n\n/m do |match|
      decoded = Base64.decode64($1)
      decoded.gsub! /"/, '\\"'
      "\"#{decoded}\"\n"
    end
    content = content.force_encoding('utf-8')
    File.open(path, 'w') { |f| f.write content }
  end
end
