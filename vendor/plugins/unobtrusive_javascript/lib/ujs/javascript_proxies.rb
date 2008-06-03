module ActionView
  module Helpers
    class JavaScriptProxy
      public :method_missing
      
      protected 
      
      def wrap(function, *args)
        args = [function_chain[-1].chomp(';')].concat(args.collect(&:to_json)).join(', ')
        replace_line("#{function.to_s}(#{args});")
      end
      
      def replace_line(new_line)
        function_chain[-1] = new_line
      end
      
    end
  end
end


module UJS
  module JavascriptProxies
    
    class ReferencedJavascriptElementProxy < ActionView::Helpers::JavaScriptElementProxy
      
      def initialize(generator, var)
        @generator = generator
        @generator << var
      end
      
      def reload; end
      
    end
      
    class JavascriptArgumentProxy
      def initialize(proxy, *contructor_args)
        @proxy, @args = proxy, contructor_args
      end
      
      def method_missing(meth, *args)
        proxy = @proxy.new(*@args)
        proxy.__send__(meth, *args)
      end
    end
    
    class JavascriptEventProxy < ActionView::Helpers::JavaScriptProxy
      def stop
        wrap('Event.stop')
      end
      
      def element
        wrap('Event.element')
      end
    end 
  end
end