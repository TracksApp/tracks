$:.unshift File.join(File.dirname(__FILE__), "..")
require "skinny_spec"

module LuckySneaks
  module ControllerSpecHelpers # :nodoc:
    include LuckySneaks::CommonSpecHelpers
    include LuckySneaks::ControllerRequestHelpers
    include LuckySneaks::ControllerStubHelpers
    
    def self.included(base)
      base.extend ExampleGroupMethods
      base.extend ControllerRequestHelpers::ExampleGroupMethods
    end
    
    # Evaluates the specified block for each of the RESTful controller methods.
    # This is useful to spec that all controller methods redirect when no user is
    # logged in.
    def with_default_restful_actions(params = {}, &block)
      {
        :get => :index,
        :get => :new,
        :post => :create
      }.each do |method_id, message|
        self.send method_id, message, params
        block.call
      end
      {
        :get => :edit,
        :put => :update,
        :delete => :destroy
      }.each do |method_id, message|
        if params[:before]
          params.delete(:before).call
        end
        # Presuming any id will do
        self.send method_id, message, params.merge(:id => 1)
        block.call
      end
    end
    
  private
    def create_ar_class_expectation(name, method, argument = nil, options = {})
      args = []
      unless options.delete(:only_method)
        args << argument unless argument.nil?
        args << hash_including(options) unless options.empty?
      end
      method = options.delete(:find_method) if options[:find_method]
      if args.empty?
        class_for(name).should_receive(method).and_return(instance_for(name))
      else
        class_for(name).should_receive(method).with(*args).and_return(instance_for(name))
      end
    end
    
    def create_positive_ar_instance_expectation(name, method, *args)
      instance = instance_for(name)
      if args.empty?
        instance.should_receive(method).and_return(true)
      else
        instance.should_receive(method).with(*args).and_return(true)
      end
    end
    
    # These methods are designed to be used at the example group [read: "describe"] level
    # to simplify and DRY up common expectations.
    module ExampleGroupMethods
      # Creates an expectation that the controller method calls <tt>ActiveRecord::Base.find</tt>.
      # Examples:
      # 
      #   it_should_find :foos                                      # => Foo.should_receive(:find).with(:all)
      #   it_should_find :foos, :all                                # An explicit version of the above
      #   it_should_find :foos, :conditions => {:foo => "bar"}      # => Foo.should_receive(:find).with(:all, :conditions => {"foo" => "bar"}
      #   it_should_find :foos, "joe", :method => :find_all_by_name # Foo.should_receive(:find_all_by_name).with("joe")
      #   it_should_find :foo                                       # => Foo.should_recieve(:find).with(@foo.id.to_s)
      #   it_should_find :foo, :params => "id"                      # => Foo.should_receive(:find).with(params[:id].to_s)
      #   it_should_find :foo, 2                                    # => Foo.should_receive(:find).with("2")
      #   it_should_find :foo, "joe", :method => :find_by_name      # => Foo.should_recieve(:find_by_name).with("joe")
      # 
      # <b>Note:</b> All params (key and value) will be strings if they come from a form element and are handled
      # internally with this expectation.
      def it_should_find(name, *args)
        name_string = name.to_s
        name_message = if name_string == name_string.singularize
          "a #{name}"
        else
          name
        end
        it "should find #{name_message}" do
          options = args.extract_options!
          # Blech!
          argument = if param = params[options.delete(:params)]
            param.to_s
          else
            if args.first
              args.first
            elsif (instance = instance_variable_get("@#{name}")).is_a?(ActiveRecord::Base)
              instance.id.to_s
            else
              :all
            end
          end
          find_method = options.delete(:method) || :find
          create_ar_class_expectation name, find_method, argument, options
          eval_request
        end
      end
      
      # Negative version of <tt>it_should_find</tt>. This creates an expectation that
      # the class never receives <tt>find</tt> at all.
      def it_should_not_find(name)
        name_string = name.to_s
        name_message = if name_string == name_string.singularize
          "a #{name}"
        else
          name
        end
        it "should not find #{name_message}" do
          if name_string == name_string.singularize
            class_for(name).should_not_receive(:find)
          else
            class_for(name).should_not_receive(:find).with(:all)
          end
          eval_request
        end
      end
      
      # Creates an expectation that the controller method calls <tt>ActiveRecord::Base.new</tt>.
      # Takes optional <tt>params</tt> for the initialization arguments. Example
      # 
      #   it_should_initialize :foo                  # => Foo.should_receive(:new)
      #   it_should_initialize :foo, :params => :bar # => Foo.should_receive(:new).with(params[:bar])
      #   it_should_initialize :foo, :bar => "baz"   # => Foo.should_receive(:new).with(:bar => "baz")
      def it_should_initialize(name, options = {})
        it "should initialize a #{name}" do
          create_ar_class_expectation name, :new, params[options.delete(:params)], options
          eval_request
        end
      end
      
      # Negative version of <tt>it_should_initialize</tt>. This creates an expectation
      # that the class never recieves <tt>new</tt> at all.
      def it_should_not_initialize(name)
        it "should initialize a #{name}" do
          class_for(name).should_not_receive(:new)
          eval_request
        end
      end
      
      # Creates an expectation that the controller method calls <tt>ActiveRecord::Base#save</tt> on the
      # named instance. Example:
      #
      #   it_should_save :foo # => @foo.should_receive(:save).and_return(true)
      # 
      # <b>Note:</b> This helper should not be used to spec a failed <tt>save</tt> call. Use <tt>it_should_assign</tt>
      # instead, to verify that the instance is captured in an instance variable for the inevitable re-rendering
      # of the form template.
      def it_should_save(name)
        it "should save the #{name}" do
          create_positive_ar_instance_expectation name, :save
          eval_request
        end
      end
      
      # Negative version of <tt>it_should_update</tt>. This creates an expectation
      # that the instance never receives <tt>save</tt> at all.
      def it_should_not_save(name)
        it "should not save the #{name}" do
          instance_for(name).should_not_receive(:save)
          eval_request
        end
      end
      
      # Creates an expectation that the controller method calls <tt>ActiveRecord::Base#update_attributes</tt>
      # on the named instance. Takes optional argument for <tt>params</tt> to specify in the
      # expectation. Examples:
      #
      #   it_should_update :foo                  # => @foo.should_receive(:update_attributes).and_return(true)
      #   it_should_update :foo, :params => :bar # => @foo.should_receive(:update_attributes).with(params[:bar]).and_return(true)
      # 
      # <b>Note:</b> This helper should not be used to spec a failed <tt>update_attributes</tt> call. Use
      # <tt>it_should_assign</tt> instead, to verify that the instance is captured in an instance variable
      # for the inevitable re-rendering of the form template.
      def it_should_update(name, options = {})
        it "should update the #{name}" do
          create_positive_ar_instance_expectation name, :update_attributes, params[name]
          eval_request
        end
      end
      
      # Negative version of <tt>it_should_update</tt>. This creates an expectation
      # that the instance never receives <tt>update_attributes</tt> at all.
      def it_should_not_update(name)
        it "should not update the #{name}" do
          instance_for(name).should_not_receive(:update_attributes)
          eval_request
        end
      end
      
      # Creates an expectation that the controller method calls <tt>ActiveRecord::Base#destroy</tt> on the named
      # instance. Example:
      # 
      #   it_should_destroy :foo # => @foo.should_receive(:destroy).and_return(true)
      # 
      # <b>Note:</b> This helper should not be used to spec a failed <tt>destroy</tt> call. Use
      # <tt>it_should_assign</tt> instead, if you need to verify that the instance is captured in an instance
      # variable if it is re-rendered somehow. This is probably a really edge use case.
      def it_should_destroy(name, options = {})
        it "should delete the #{name}" do
          create_positive_ar_instance_expectation name, :destroy
          eval_request
        end
      end
      
      # Negative version of <tt>it_should_destroy</tt>. This creates an expectation
      # that the instance never receives <tt>destroy</tt> at all.
      def it_should_not_destroy(name)
        it "should not destroy the #{name}" do
          instance_for(name).should_not_receive(:destroy)
          eval_request
        end
      end
      
      # Creates expectation[s] that the controller method should assign the specified 
      # instance variables along with any specified values. Examples:
      # 
      #   it_should_assign :foo               # => assigns[:foo].should == @foo
      #   it_should_assign :foo => "bar"      # => assigns[:foo].should == "bar"
      #   it_should_assign :foo => :nil       # => assigns[:foo].should be_nil
      #   it_should_assign :foo => :not_nil   # => assigns[:foo].should_not be_nil
      #   it_should_assign :foo => :undefined # => controller.send(:instance_variables).should_not include("@foo")
      # 
      # Very special thanks to Rick Olsen for the basis of this code. The only reason I even
      # redefine it at all is purely an aesthetic choice for specs like "it should foo"
      # over ones like "it foos".
      def it_should_assign(*names)
        names.each do |name|
          if name.is_a?(Symbol)
            it_should_assign name => name
          elsif name.is_a?(Hash)
            name.each do |key, value|
              it_should_assign_instance_variable key, value
            end
          end
        end
      end
      
      # Essentially shorthand for <tt>it_should_assign name => :nil</tt>. This method can take multiple
      # instance variable names, creating this shorthand for each name. See the docs for
      # <tt>it_should_assign</tt> for more information.
      def it_should_not_assign(*names)
        names.each do |name|
          # Assuming name is a symbol
          it_should_assign name => :nil
        end
      end
      
      # Wraps the separate expectations <tt>it_should_find</tt> and <tt>it_should_assign</tt>
      # for simple cases. If you need more control over the parameters of the find, this
      # isn't the right helper method and you should write out the two expectations separately.
      def it_should_find_and_assign(*names)
        names.each do |name|
          it_should_find name, :only_method => true
          it_should_assign name
        end
      end
      
      # Negative version of <tt>it_should_find_and_assign</tt>. This creates an
      # expectation that the class never receives <tt>find</tt> at all and that 
      # no matching instance variable is ever created.
      def it_should_not_find_and_assign(*names)
        names.each do |name|
          it_should_not_find name
          it_should_assign name => :nil
        end
      end
      
      # Wraps the separate expectations <tt>it_should_initialize</tt> and <tt>it_should_assign</tt>
      # for simple cases. If you need more control over the parameters of the initialization, this
      # isn't the right helper method and you should write out the two expectations separately.
      # 
      # <b>Note:</b> This method is used for controller methods like <tt>new</tt>, where the instance
      # is initialized without being saved (this includes failed <tt>create</tt> requests).
      # If you want to spec that the controller method successfully saves the instance,
      # please use <tt>it_should_initialize_and_save</tt>.
      def it_should_initialize_and_assign(*names)
        names.each do |name|
          it_should_initialize name, :only_method => true
          it_should_assign name
        end
      end
      
      # Negative version of <tt>it_should_initialize_and_assign</tt>. This creates an
      # expectation that the class never receives <tt>new</tt> at all and that 
      # no matching instance variable is ever created.
      def it_should_not_initialize_and_assign(*names)
        names.each do |name|
          it_should_not_initialize name
          it_should_assign name => :nil
        end
      end
      
      # Wraps the separate expectations <tt>it_should_initialize</tt> and <tt>it_should_save</tt>
      # for simple cases. If you need more control over the parameters of the initialization, this
      # isn't the right helper method and you should write out the two expectations separately.
      # 
      # <b>Note:</b> This method is used for controller methods like <tt>create</tt>, where the instance
      # is initialized and successfully saved. If you want to spec that the instance is created
      # but not saved, just use <tt>it_should_initialize_and_assign</tt>.
      def it_should_initialize_and_save(*names)
        names.each do |name|
          it_should_initialize name, :only_method => true
          it_should_save name
        end
      end
      
      # Wraps the separate expectations <tt>it_should_find</tt> and <tt>it_should_update</tt>
      # for simple cases. If you need more control over the parameters of the find, this
      # isn't the right helper method and you should write out the two expectations separately.
      # 
      # <b>Note:</b> This method is used for controller methods like <tt>update</tt>, where the
      # instance is loaded from the database and successfully saved. If you want to spec that the
      # instance is found but not saved, just use <tt>it_should_find_and_assign</tt>.
      def it_should_find_and_update(*names)
        names.each do |name|
          it_should_find name, :only_method => true
          it_should_update name
        end
      end
      
      # Wraps the separate expectations <tt>it_should_find</tt> and <tt>it_should_destroy</tt>
      # for simple cases. If you need more control over the parameters of the find, this
      # isn't the right helper method and you should write out the two expectations separately.
      def it_should_find_and_destroy(*names)
        names.each do |name|
          it_should_find name, :only_method => true
          it_should_destroy name
        end
      end

      # Creates an expectation that the specified collection (<tt>flash</tt>, <tt>session</tt>,
      # <tt>params</tt>, <tt>cookies</tt>) contains the specified key and value. To specify that
      # the collection should be set to <tt>nil</tt>, specify the value as :nil instead.
      def it_should_set(collection, key, value = nil, &block)
        it "should set #{collection}[:#{key}]#{' with ' + value.inspect if value}" do
          # Allow flash.now[:foo] to remain in the flash
          flash.stub!(:sweep) if collection == :flash
          eval_request
          if value
            if value == :nil
              self.send(collection)[key].should be_nil
            else
              self.send(collection)[key].should == value
            end
          elsif block_given?
            self.send(collection)[key].should == instance_eval(&block)
          else
            self.send(collection)[key].should_not be_nil
          end
        end
      end
      
      # Wraps <tt>it_should_set :flash</tt>. To specify that the collection should be set
      # to <tt>nil</tt>, specify the value as :nil instead.
      def it_should_set_flash(name, value = nil, &block)
        it_should_set :flash, name, value, &block
      end
      
      # Wraps <tt>it_should_set :flash, :nil</tt>.
      def it_should_not_set_flash(name)
        it_should_set :flash, name, :nil
      end

      # Wraps <tt>it_should_set :session</tt>. To specify that the collection should be set
      # to <tt>nil</tt>, specify the value as :nil instead.
      def it_should_set_session(name, value = nil, &block)
        it_should_set :session, name, value, &block
      end
      
      # Wraps <tt>it_should_set :session, :nil</tt>.
      def it_should_not_set_session(name)
        it_should_set :session, name, :nil
      end
      
      # Wraps <tt>it_should_set :params</tt>. To specify that the collection should be set
      # to <tt>nil</tt>, specify the value as :nil instead.
      def it_should_set_params(name, value = nil, &block)
        it_should_set :params, name, value, &block
      end
      
      # Wraps <tt>it_should_set :params, :nil</tt>.
      def it_should_not_set_params(name)
        it_should_set :params, name, :nil
      end
      
      # Wraps <tt>it_should_set :cookies</tt>. To specify that the collection should be set
      # to <tt>nil</tt>, specify the value as :nil instead.
      def it_should_set_cookies(name, value = nil, &block)
        it_should_set :cookies, name, value, &block
      end
      
      # Wraps <tt>it_should_set :cookies, :nil</tt>.
      def it_should_not_set_cookies(name)
        it_should_set :cookies, name, :nil
      end
      
      # Wraps the various <tt>it_should_render_<i>foo</i></tt> methods:
      # <tt>it_should_render_template</tt>, <tt>it_should_render_partial</tt>,
      # <tt>it_should_render_xml</tt>, <tt>it_should_render_json</tt>,
      # <tt>it_should_render_formatted</tt>, and <tt>it_should_render_nothing</tt>.
      def it_should_render(render_method, *args)
        send "it_should_render_#{render_method}", *args
      end

      # Creates an expectation that the controller method renders the specified template.
      # Accepts the following options which create additional expectations.
      # 
      #   <tt>:content_type</tt>:: Creates an expectation that the Content-Type header for the response
      #                            matches the one specified
      #   <tt>:status</tt>::       Creates an expectation that the HTTP status for the response
      #                            matches the one specified
      def it_should_render_template(name, options = {})
        create_status_expectation options[:status] if options[:status]
        it "should render '#{name}' template" do
          eval_request
          response.should render_template(name)
        end
        create_content_type_expectation(options[:content_type]) if options[:content_type]
      end
      
      # Creates an expectation that the controller method renders the specified partial.
      # Accepts the following options which create additional expectations.
      # 
      #   <tt>:content_type</tt>:: Creates an expectation that the Content-Type header for the response
      #                            matches the one specified
      #   <tt>:status</tt>::       Creates an expectation that the HTTP status for the response
      #                            matches the one specified
      def it_should_render_partial(name, options = {})
        create_status_expectation options[:status] if options[:status]
        it "should render '#{name}' partial" do
          controller.expect_render(:partial => name)
          eval_request
        end
        create_content_type_expectation(options[:content_type]) if options[:content_type]
      end

      # Creates an expectation that the controller method renders the specified record via <tt>to_xml</tt>.
      # Accepts the following options which create additional expectations.
      # 
      #   <tt>:content_type</tt>:: Creates an expectation that the Content-Type header for the response
      #                            matches the one specified
      #   <tt>:status</tt>::       Creates an expectation that the HTTP status for the response
      #                            matches the one specified
      def it_should_render_xml(record = nil, options = {}, &block)
        it_should_render_formatted :xml, record, options, &block
      end

      # Creates an expectation that the controller method renders the specified record via <tt>to_json</tt>.
      # Accepts the following options which create additional expectations.
      # 
      #   <tt>:content_type</tt>:: Creates an expectation that the Content-Type header for the response
      #                            matches the one specified
      #   <tt>:status</tt>::       Creates an expectation that the HTTP status for the response
      #                            matches the one specified
      def it_should_render_json(record = nil, options = {}, &block)
        it_should_render_formatted :json, record, options, &block
      end

      # Called internally by <tt>it_should_render_xml</tt> and <tt>it_should_render_json</tt>
      # but should not really be called much externally unless you have defined your own
      # formats with a matching <tt>to_foo</tt> method on the record.
      # 
      # Which is probably never.
      def it_should_render_formatted(format, record = nil, options = {}, &block)
        create_status_expectation options[:status] if options[:status]
        it "should render #{format.inspect}" do
          if record.is_a?(Hash)
            options = record
            record = nil
          end
          if record.nil? && !block_given?
            raise ArgumentError, "it_should_render must be called with either a record or a block and neither was given."
          else
            if record
              pieces = record.to_s.split(".")
              record = instance_variable_get("@#{pieces.shift}")
              record = record.send(pieces.shift) until pieces.empty?
            end
            block ||= proc { record.send("to_#{format}") }
            get_response do |response|
              response.should have_text(block.call)
            end
          end
        end
        create_content_type_expectation(options[:content_type]) if options[:content_type]
      end

      # Creates an expectation that the controller method returns a blank page. You'd already 
      # know when and why to use this so I'm not typing it out.
      def it_should_render_nothing(options = {})
        create_status_expectation options[:status] if options[:status]
        it "should render :nothing" do
          get_response do |response|
            response.body.strip.should be_blank
          end
        end
      end
      
      # Creates an expectation that the controller method redirects to the specified destination. Example:
      # 
      #   it_should_redirect_to { foos_url }
      # 
      # <b>Note:</b> This method takes a block to evaluate the route in the example
      # context rather than the example group context.
      def it_should_redirect_to(hint = nil, &route)
        if hint.nil? && route.respond_to?(:to_ruby)
          hint = route.to_ruby.gsub(/(^proc \{)|(\}$)/, '').strip
        end
        it "should redirect to #{(hint || route)}" do
          eval_request
          response.should redirect_to(instance_eval(&route))
        end
      end
      
      # Negative version of <tt>it_should_redirect_to</tt>.
      def it_should_not_redirect_to(hint = nil, &route)
        if hint.nil? && route.respond_to?(:to_ruby)
          hint = route.to_ruby.gsub(/(^proc \{)|(\}$)/, '').strip
        end
        it "should not redirect to #{(hint || route)}" do
          eval_request
          response.should_not redirect_to(instance_eval(&route))
        end
      end
      
      # Creates an expectation that the controller method redirects back to the previous page
      def it_should_redirect_to_referer
        it "should redirect to the referring page" do
          request.env["HTTP_REFERER"] = "http://test.host/referer"
          eval_request
          response.should redirect_to("http://test.host/referer")
        end
      end
      alias it_should_redirect_to_referrer it_should_redirect_to_referer
      
    private
      def it_should_assign_instance_variable(name, value)
        expectation_proc = case value
          when :nil
            proc { assigns[name].should be_nil }
          when :not_nil
            proc { assigns[name].should_not be_nil }
          when :undefined
            proc { controller.send(:instance_variables).should_not include("@{name}") }
          when Symbol
            if (instance_variable = instance_variable_get("@#{name}")).nil?
              proc { assigns[name].should_not be_nil }
            else
              proc { assigns[name].should == instance_variable }
            end
          else
            proc { assigns[name].should == value }
          end
        it "should #{value == :nil ? 'not ' : ''}assign @#{name}" do
          eval_request
          instance_eval &expectation_proc
        end
      end
    end
  end
end