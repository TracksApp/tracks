module ActiveRecord
  module Reflection
    
    module ClassMethods
      def create_reflection(macro, name, options, active_record)
        case macro
          when :has_many, :belongs_to, :has_one, :has_and_belongs_to_many
            reflection = AssociationReflection.new(macro, name, options, active_record)
          when :composed_of
            reflection = AggregateReflection.new(macro, name, options, active_record)
        ######
          when :has_many_polymorphs
            reflection = PolymorphicReflection.new(macro, name, options, active_record)
        ######
        end
        write_inheritable_hash :reflections, name => reflection
        reflection
      end
    end

    class PolymorphicError < ActiveRecordError
    end
    
    class PolymorphicReflection < AssociationReflection
      def check_validity!          
        # nothing
      end                 

      # these are kind of shady but it lets us inherit more directly
      def source_reflection
        self
      end      
      
      def class_name
        @class_name ||= options[:join_class_name]
      end
                     
    end
 
  end
end
