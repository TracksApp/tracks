# WSDL4R - XMLSchema import handler.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/xmlSchema/importer'


module WSDL
module XMLSchema


class ImportHandler
  attr_reader :schemalocation
  attr_reader :content

  def initialize
    @schemalocation = nil
    @content = nil
  end

  def parse_schemalocation(location, root, parent)
    @schemalocation = URI.parse(location)
    if @schemalocation.relative? and !parent.location.nil? and
        !parent.location.relative?
      @schemalocation = parent.location + @schemalocation
    end
    if root.importedschema.key?(@schemalocation)
      @content = root.importedschema[@schemalocation]
    else
      root.importedschema[@schemalocation] = nil      # placeholder
      @content = Importer.import(@schemalocation, root)
      root.importedschema[@schemalocation] = @content
    end
    @schemalocation
  end
end


end
end
