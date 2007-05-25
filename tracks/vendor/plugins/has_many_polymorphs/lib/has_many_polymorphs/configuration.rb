
### deprecated

if defined? Rails::Configuration
  class Rails::Configuration
    def has_many_polymorphs_cache_classes= *args
      ::ActiveRecord::Associations::ClassMethods.has_many_polymorphs_cache_classes = *args
    end
  end
end

module ActiveRecord      
  module Associations      
    module ClassMethods
      mattr_accessor :has_many_polymorphs_cache_classes
    end
  end
end
