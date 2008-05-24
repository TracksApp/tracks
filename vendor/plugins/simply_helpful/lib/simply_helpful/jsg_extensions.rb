module ActionView
  module Helpers
    module PrototypeHelper
      class JavaScriptGenerator
        module GeneratorMethods
          def [](id)
            case id
              when String, Symbol, NilClass
                JavaScriptElementProxy.new(self, id)
              else
                JavaScriptElementProxy.new(self, SimplyHelpful::RecordIdentifier.dom_id(id))
            end
          end
        end
      end
    end
  end
end