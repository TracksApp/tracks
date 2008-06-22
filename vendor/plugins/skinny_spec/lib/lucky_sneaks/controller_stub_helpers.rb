module LuckySneaks # :nodoc:
  # These methods are designed to be used in your example <tt>before</tt> blocks to accomplish
  # a whole lot of functionality with just a tiny bit of effort. The methods which correspond
  # to the controller methods perform the most duties as they create the mock_model instances,
  # stub out all the necessary methods, and also create implicit requests to DRY up your spec
  # file even more. You are encouraged to use these methods to setup the basic calls for your
  # resources and only resort to the other methods when mocking and stubbing secondary objects
  # and calls.
  # 
  # Both <tt>stub_create</tt> and <tt>stub_update</tt> benefit from having a <tt>valid_attributes</tt>
  # method defined at the top level of your example groups, ie the top-most "describe" block
  # of the spec file. If you did not generate your specs with <tt>skinny_scaffold</tt> or
  # <tt>skinny_resourceful</tt> generators, you can simply write a method like the following
  # for yourself:
  # 
  #   def valid_attributes
  #     {
  #       "foo" => "bar",
  #       "baz" => "quux"
  #     }
  #   end
  # 
  # Note this method employs strings as both the key and values to best replicate the way
  # they are used in actual controllers where the params will come from a form.
  module ControllerStubHelpers
    # Stubs out <tt>find :all</tt> and returns a collection of <tt>mock_model</tt>
    # instances of that class. Accepts the following options:
    # 
    # <b>:format</b>:: Format of the request. Used to only add <tt>to_xml</tt> and 
    #                  <tt>to_json</tt> when actually needed.
    # <b>:size</b>::   Number of instances to return in the result. Default is 3.
    # <b>:stub</b>::   Additional methods to stub on the instances
    # 
    # Any additional options will be passed as arguments to the class find.
    # You will want to make sure to pass those arguments to the <tt>it_should_find</tt> spec as well.
    def stub_find_all(klass, options = {})
      returning(Array.new(options[:size] || 3){mock_model(klass)}) do |collection|
        stub_out klass, options.delete(:stub)
        if format = options.delete(:format)
          stub_formatted collection, format
          params[:format] = format
        end
        if options.empty?
          klass.stub!(:find).with(:all).and_return(collection)
        else
          klass.stub!(:find).with(:all, options).and_return(collection)
        end
      end
    end
    
    # Alias for <tt>stub_find_all</tt> but additionally defines an implicit request <tt>get :index</tt>.
    def stub_index(klass, options = {})
      define_implicit_request :index
      stub_find_all klass, options
    end
    
    # Stubs out <tt>new</tt> method and returns a <tt>mock_model</tt> instance marked as a new record.
    # Accepts the following options:
    # 
    # <b>:format</b>::    Format of the request. Used to only add <tt>to_xml</tt> and 
    #                     <tt>to_json</tt> when actually needed.
    # <b>:stub</b>::      Additional methods to stub on the instances
    #
    # It also accepts some options used to stub out <tt>save</tt> with a specified <tt>true</tt>
    # or <tt>false</tt> but you should be using <tt>stub_create</tt> in that case.
    def stub_initialize(klass, options = {})
      returning mock_model(klass) do |member|
        stub_out member, options.delete(:stub)
        if format = options[:format]
          stub_formatted member, format
          params[:format] = format
        end
        klass.stub!(:new).and_return(member)
        if options[:stub_save]
          stub_ar_method member, :save, options[:return]
          klass.stub!(:new).with(params[options[:params]]).and_return(member)
        else
          member.stub!(:new_record?).and_return(true)
          member.stub!(:id).and_return(nil)
        end
      end
    end
    
    # Alias for <tt>stub_initialize</tt> which additionally defines an implicit request <tt>get :new</tt>.
    def stub_new(klass, options = {})
      define_implicit_request :new
      stub_initialize klass, options
    end
    
    # Alias for <tt>stub_initialize</tt> which additionally defines an implicit request <tt>post :create</tt>.
    # 
    # <b>Note:</b> If <tt>stub_create<tt> is provided an optional <tt>:params</tt> hash
    # or the method <tt>valid_attributes</tt> is defined within its scope,
    # those params will be added to the example's <tt>params</tt> object. If <i>neither</i>
    # are provided an <tt>ArgumentError</tt> will be raised.
    def stub_create(klass, options = {})
      define_implicit_request :create
      if options[:params].nil?
        if self.respond_to?(:valid_attributes)
          params[klass.name.underscore.to_sym] = valid_attributes
          options[:params] = valid_attributes
        else
          error_message = "Params for creating #{klass} could not be determined. "
          error_message << "Please define valid_attributes method in the base 'describe' block "
          error_message << "or manually set params in the before block."
          raise ArgumentError, error_message
        end
      end
      stub_initialize klass, options.merge(:stub_save => true)
    end
    
    # Stubs out <tt>find</tt> and returns a single <tt>mock_model</tt>
    # instances of that class. Accepts the following options:
    # 
    # <b>:format</b>::  Format of the request. Used to only add <tt>to_xml</tt> and 
    #                   <tt>to_json</tt> when actually needed.
    # <b>:stub</b>::    Additional methods to stub on the instances
    # 
    # Any additional options will be passed as arguments to <tt>find</tt>.You will want
    # to make sure to pass those arguments to the <tt>it_should_find</tt> spec as well.
    # 
    # <b>Note:</b> The option <tt>:stub_ar</tt> is used internally by <tt>stub_update</tt>
    # and <tt>stub_destroy</tt>. If you need to stub <tt>update_attributes</tt> or 
    # <tt>destroy</tt> you should be using the aforementioned methods instead.
    def stub_find_one(klass, options = {})
      returning mock_model(klass) do |member|
        stub_out member, options.delete(:stub)
        if options[:format]
          stub_formatted member, options[:format]
          params[:format] = options[:format]
        end
        if options[:current_object]
          params[:id] = member.id
          if options[:stub_ar]
            stub_ar_method member, options[:stub_ar], options[:return]
          end
        end
        klass.stub!(:find).with(member.id.to_s).and_return(member)
      end
    end
    
    # Alias for <tt>stub_find_one</tt> which additionally defines an implicit request <tt>get :show</tt>.
    def stub_show(klass, options = {})
      define_implicit_request :show
      stub_find_one klass, options.merge(:current_object => true)
    end

    # Alias for <tt>stub_find_one</tt> which additionally defines an implicit request <tt>get :edit</tt>.
    def stub_edit(klass, options = {})
      define_implicit_request :edit
      stub_find_one klass, options.merge(:current_object => true)
    end

    # Alias for <tt>stub_find_one</tt> which additionally defines an implicit request <tt>put :update</tt>
    # and stubs out the <tt>update_attribute</tt> method on the instance as well.
    # 
    # <b>Note:</b> If <tt>stub_update<tt> is provided an optional <tt>:params</tt> hash
    # or the method <tt>valid_attributes</tt> is defined within its scope,
    # those params will be added to the example's <tt>params</tt> object. If <i>neither</i>
    # are provided an <tt>ArgumentError</tt> will be raised.
    def stub_update(klass, options = {})
      define_implicit_request :update
      stub_find_one klass, options.merge(:current_object => true, :stub_ar => :update_attributes)
    end

    # Alias for <tt>stub_find_one</tt> which additionally defines an implicit request <tt>delete :destroy</tt>
    # and stubs out the <tt>destroy</tt> method on the instance as well.
    def stub_destroy(klass, options = {})
      define_implicit_request :destroy
      stub_find_one klass, options.merge(:current_object => true, :stub_ar => :destroy)
    end
    
    # Stubs <tt>to_xml</tt> or <tt>to_json</tt> respectively based on <tt>format</tt> argument.
    def stub_formatted(object, format)
      return unless format
      object.stub!("to_#{format}").and_return("#{object.class} formatted as #{format}")
    end
    
  private
    # Stubs out multiple methods. You shouldn't be calling this yourself and if you do
    # you should be able to understand the code yourself, right?
    def stub_out(object, stubs = {})
      return if stubs.nil?
      stubs.each do |method, value|
        if value
          object.stub!(method).and_return(value)
        else
          object.stub!(method)
        end
      end
    end
    
    # Stubs out ActiveRecord::Base methods like #save, #update_attributes, etc
    # that may be called on a found or instantiated mock_model instance.
    def stub_ar_method(object, method, return_value)
      object.stub!(method).and_return(return_value ? false : true)
    end
  end
end
