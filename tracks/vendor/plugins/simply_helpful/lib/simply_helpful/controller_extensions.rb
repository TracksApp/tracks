module SimplyHelpful
  module ActionControllerExtensions
    def self.included(base)
      base.helper_method :polymorphic_url
      base.helper_method :polymorphic_path
    end

    def polymorphic_url(record)
      SimplyHelpful::RecordIdentifier.polymorphic_url(record, self)
    end

    def polymorphic_path(record)
      SimplyHelpful::RecordIdentifier.polymorphic_path(record, self)
    end
    
    def redirect_to_with_record_identification(*args)
      return redirect_to_without_record_identification *args unless args.size == 1
      
      potential_object = args.first

      case potential_object
      when String, Symbol, Hash
        redirect_to_without_record_identification *args
      else
        redirect_to_without_record_identification SimplyHelpful::RecordIdentifier.polymorphic_url(potential_object, self)
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
