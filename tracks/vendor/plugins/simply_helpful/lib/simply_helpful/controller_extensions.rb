module SimplyHelpful
  module ActionControllerExtensions
    POLYMORPHIC_ROUTES = %w(
      polymorphic_url polymorphic_path
      edit_polymorphic_url edit_polymorphic_path
      new_polymorphic_url new_polymorphic_path
      formatted_polymorphic_url formatted_polymorphic_path
     )
    
    def self.included(base)
      POLYMORPHIC_ROUTES.each { |route| base.helper_method(route) }
    end

    POLYMORPHIC_ROUTES.each do |route|
      module_eval <<-EOT
        def #{route}(record)
          SimplyHelpful::PolymorphicRoutes.#{route}(record, self)
        end
      EOT
    end
    
    def redirect_to_with_record_identification(*args)
      return redirect_to_without_record_identification *args unless args.size == 1
      
      potential_object = args.first

      case potential_object
      when String, Symbol, Hash
        redirect_to_without_record_identification *args
      else
        redirect_to_without_record_identification SimplyHelpful::PolymorphicRoutes.polymorphic_url(potential_object, self)
      end
    end
  end
end

module ActionController
  class Base
    include SimplyHelpful::ActionControllerExtensions
    alias_method_chain :redirect_to, :record_identification
  end
end