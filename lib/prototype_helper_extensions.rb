module ActionView
  module Helpers
    module PrototypeHelper

      def remote_to_href(options = {})
        remote_function(options.merge(:url => javascript_variable('this.href'))) + "\n"
      end

      class JavaScriptGenerator #:nodoc:
        module GeneratorMethods
          
          # Executes the content of the block if the user confirms the javascript confirmation. Example:
          #
          #   page.confirming("Are you sure?") do
          #     page.visual_effect :hide, 'information'
          #   end
          def confirming(message)
            message = "'#{message}'" unless message =~ /^['"]/
            self << "if (confirm(#{message})) {"
            yield
            self << "}"
          end
        end
      end
    end
  end
end