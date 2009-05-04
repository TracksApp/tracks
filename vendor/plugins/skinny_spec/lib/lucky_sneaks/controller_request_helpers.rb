module LuckySneaks
  module ControllerRequestHelpers # :nodoc:
    def self.included(base)
      base.extend ExampleGroupMethods
    end
    
  private
    def define_implicit_request(method)
      @controller_method = method
      @implicit_request = case method
      when :index, :new, :show, :edit
        proc { get method, params }
      when :create
        proc { post :create, params }
      when :update
        proc { put :update, params }
      when :destroy
        proc { put :destroy, params }
      end
    end
    
    def eval_request
      instance_eval &self.class.instance_variable_get("@the_request")
    rescue ArgumentError # missing block
      try_shared_request_definition
    end
    alias do_request eval_request

    def try_shared_request_definition
      if defined?(shared_request) == "method"
        shared_request
      elsif @implicit_request
        try_implicit_request
      else
        error_message = "Could not determine request definition for 'describe' context. "
        error_message << "Please use define_request or define a shared_request."
        raise ArgumentError, error_message
      end
    end

    def try_implicit_request
      @implicit_request.call
    end
    
    def get_response(&block)
      eval_request
      block.call(response) if block_given?
      response
    end
    
    module ExampleGroupMethods
      # Defines a request at the example group ("describe") level to be evaluated in the examples. Example:
      # 
      #   define_request { get :index, params }
      # 
      # <b>Note:</b> The following methods all define implicit requests: <tt>stub_index</tt>, <tt>stub_new</tt>,
      # <tt>stub_create</tt>, <tt>stub_show</tt>, <tt>stub_edit</tt>, <tt>stub_update</tt>, and
      # <tt>stub_destroy</tt>. Using them in your <tt>before</tt> blocks will allow you to forego
      # defining explicit requests using <tt>define_request</tt>. See
      # LuckySneaks::ControllerStubHelpers for information on these methods.
      def define_request(&block)
        raise ArgumentError, "Must provide a block to define a request!" unless block_given?
        @the_request = block
      end
    end
  end
end
