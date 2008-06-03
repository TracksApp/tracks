module ActionView
  module Helpers
    module FormHelper
      def form_for_with_record_identification(name_or_object, *args, &proc)
        form_method_with_record_identification :form_for, name_or_object, *args, &proc
      end
      
      alias_method_chain :form_for, :record_identification
      
      protected
        def form_method_with_record_identification(method_name, name_or_object, *args, &proc)
          old_method_name = "#{method_name}_without_record_identification"
          case name_or_object
            when String, Symbol, NilClass
              send(old_method_name, name_or_object, *args, &proc)
            else
              options = args.first || {}
          
              object_name = SimplyHelpful::RecordIdentifier.singular_class_name(name_or_object)
              object      = name_or_object
              url         = SimplyHelpful::PolymorphicRoutes.polymorphic_url(object, self)
          
              html_options = if object.new_record?
                { :class  => dom_class(object, :new),  :id => dom_id(object), :method => :post }
              else
                { :class  => dom_class(object, :edit), :id => dom_id(object, :edit), :method => :put }
              end
          
              send(old_method_name, 
                object_name, object, options.merge({ :url => url, :html => html_options.update(options[:html] || {}) }), &proc
              )
          end
        end
    end
  end
end

module ActionView
  module Helpers
    module PrototypeHelper
      def remote_form_for_with_record_identification(name_or_object, *args, &proc)
        form_method_with_record_identification :remote_form_for, name_or_object, *args, &proc
      end

      alias_method_chain :remote_form_for, :record_identification
    end
  end
end
