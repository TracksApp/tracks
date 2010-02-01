require 'mysample_mapping_registry.rb'

module XSD; module XSD2Ruby

class MysampleMapper < XSD::Mapping::Mapper
  def initialize
    super(MysampleMappingRegistry::Registry)
  end
end

end; end
