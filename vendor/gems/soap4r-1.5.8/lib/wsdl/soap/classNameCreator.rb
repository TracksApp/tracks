# WSDL4R - Class name creator.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'


module WSDL
module SOAP


class ClassNameCreator
  include XSD::CodeGen::GenSupport

  def initialize
    @classname = {}
  end

  def assign_name(qname, modulepath = nil)
    key = [modulepath, qname]
    unless @classname.key?(key)
      if klass = ::SOAP::TypeMap[qname]
        name =
          ::SOAP::Mapping::DefaultRegistry.find_mapped_obj_class(klass).name
      else
        name = safeconstname(qname.name)
        if modulepath
          name = [modulepath, name].join('::')
        end
        while @classname.value?(name)
          name += '_'
        end
        check_classname(name)
      end
      @classname[key] = name.freeze
    end
    @classname[key]
  end

  def check_classname(name)
    if Object.constants.include?(name)
      warn("created definition re-opens an existing toplevel class: #{name}.  consider to use --module_path option of wsdl2ruby.rb")
    end
  end
end


end
end
