module LuckySneaks # :nodoc:
  # These methods are designed to be used in your example <tt>before</tt> blocks to accomplish
  # a whole lot of functionality with just a tiny bit of effort. The methods which correspond
  # to the controller methods perform the most duties as they create the mock_model instances,
  # stub out all the necessary methods, and also create implicit requests to DRY up your spec
  # file even more. You are encouraged to use these methods to setup the basic calls for your
  # resources and only resort to the other methods when mocking and stubbing secondary objects
  # and calls.
  module ControllerStubHelpers
    # Stubs out <tt>find :all</tt> and returns a collection of <tt>mock_model</tt>
    # instances of that class. Accepts the following options:
    # 
    # <b>:find_method</b>:: Method to use as finder call. Default is <tt>:find</tt>.
    #                  <b>Note:</b> When specifying the method, the call is stubbed
    #                  to accept any arguments. Caveat programmer.
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
        if find_method = options[:find_method]
          # Not stubbing specific arguments here
          # If you need more specificity, write a custom example
          klass.stub!(find_method).and_return(collection)
        else
          klass.stub!(:find).with(:all).and_return(collection)
          klass.stub!(:find).with(:all, hash_including(options)).and_return(collection)
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
        if options[:params]
          klass.stub!(:new).with(hash_including(options[:params])).and_return(member)
        end
        if options[:stub_save]
          stub_ar_method member, :save, options[:return]
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
    # <b>Note:</b> If <tt>stub_create<tt> is provided an optional <tt>:params</tt> hash,
    # those params will be added to the example's <tt>params</tt> object.
    def stub_create(klass, options = {})
      define_implicit_request :create
      class_name = klass.name.underscore
      options[:params] ||= params[class_name]
      stub_initialize klass, options.merge(:stub_save => true)
    end
    
    # Stubs out <tt>find</tt> and returns a single <tt>mock_model</tt>
    # instances of that class. Accepts the following options:
    # 
    # <b>:find_method</b>:: Method to use as finder call. Default is <tt>:find</tt>.
    # <b>:format</b>:: Format of the request. Used to only add <tt>to_xml</tt> and 
    #                  <tt>to_json</tt> when actually needed.
    # <b>:stub</b>::   Additional methods to stub on the instances
    # <b>:current_object</b>:: If set to true, <tt>find</tt> will set <tt>params[:id]</tt>
    #                          using the <tt>id</tt> of the <tt>mock_model</tt> instance
    #                          and use that value as an argument when stubbing <tt>find</tt>
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
        if format = options.delete(:format)
          stub_formatted member, format
          params[:format] = format
        end
        if options.delete(:current_object)
          params[:id] = member.id
          if ar_stub = options.delete(:stub_ar)
            stub_ar_method member, ar_stub, options.delete(:return), options.delete(:update_params)
          end
        end
        if find_method = options.delete(:find_method)
          klass.stub!(find_method).and_return(member)
        else
          # Stubbing string and non-string just to be safe
          klass.stub!(:find).with(member.id).and_return(member)
          klass.stub!(:find).with(member.id.to_s).and_return(member)
          unless options.empty?
            klass.stub!(:find).with(member.id, hash_including(options)).and_return(member)
            klass.stub!(:find).with(member.id.to_s, hash_including(options)).and_return(member)
          end
        end
      end
    end
    
    # <b>Note:</b> Use of this method with :child options (to mock
    # association) is deprecated. Please use <tt>stub_association</tt>.
    # 
    # Same as <tt>stub_find_one</tt> but setups the instance as the parent
    # of the specified association. Example:
    # 
    #   stub_parent(Document, :child => :comments)
    # 
    # This stubs <tt>Document.find</tt>, <tt>@document.comments</tt> (which
    # will return <tt>Comment</tt> class), as well as <tt>params[:document_id]</tt>.
    # This method is meant to be used in the controller for the specified child
    # (<tt>CommentsController</tt> in this instance) in situations like:
    # 
    #   def index
    #     @document = Document.find(params[:document_id])
    #     @comments = @document.comments.find(:all)
    #   end
    def stub_parent(klass, options = {})
      returning stub_find_one(klass, options) do |member|
        params[klass.name.foreign_key] = member.id
        if offspring = options.delete(:child)
          puts "stub_parent with :child option has been marked for deprecation"
          puts "please use stub_association to create the mock instead"
          member.stub!(offspring).and_return(class_for(offspring))
        end
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
    # <b>Note:</b> If <tt>stub_update<tt> is provided an optional <tt>:params</tt> hash,
    # those params will be added to the example's <tt>params</tt> object.
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
    
    # Creates a mock object representing an association proxy, stubs the appropriate 
    # method on the parent object and returns that association proxy.
    # Accepts the following option:
    # 
    # <b>:stub</b>::   Additional methods to stub on the mock proxy object
    def stub_association(object, association, options = {})
      # I know options isn't implemented anywhere
      object_name = instance_variables.select{|name| instance_variable_get(name) == object}
      returning mock("Association proxy for #{object_name}.#{association}") do |proxy|
        stub_out proxy, options[:stub] if options[:stub]
        object.stub!(association).and_return(proxy)
      end
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
    def stub_ar_method(object, method, return_value, params = {})
      if params.blank?
        object.stub!(method).and_return(return_value ? false : true)
      else
        object.stub!(method).with(hash_including(params)).and_return(return_value ? false : true)
      end
    end
  end
end
