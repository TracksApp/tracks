$:.unshift File.join(File.dirname(__FILE__), "..")
require "skinny_spec"

module LuckySneaks
  # These methods are designed to be used in your example [read: "it"] blocks
  # to make your model specs a little more DRY. You might also be interested 
  # in checking out the example block [read: "describe"] level versions in of these
  # methods which can DRY things up even more:
  # LuckySneaks::ModelSpecHelpers::ExampleGroupLevelMethods.
  # 
  # Also check out the methods in LuckySneaks::ModelSpecHelpers::AssociationMatcher
  # for some helpful matcher helper methods to use with these methods if you want to spec
  # options on your association setups.
  module ModelSpecHelpers
    include LuckySneaks::CommonSpecHelpers
    
    def self.included(base) # :nodoc:
      base.extend ExampleGroupLevelMethods
    end
    
    # These methods cannot be used alone but are used in compliment with the association
    # matchers in LuckySneaks::ModelSpecHelpers like <tt>have_many</tt>. Example:
    # 
    #   describe User do
    #     it "should have many memberships" do
    #       User.should have_many(:memberships)
    #     end
    # 
    #     it "should have many sites through memberships" do
    #       User.should have_many(:sites).through(:memberships)
    #     end
    # 
    #     it "should belong to a manager" do
    #       User.should belong_to(:manager).with_counter_cache
    #     end
    #   end
    # 
    # <b>Note:</b> To spec these sorts of options using the example block helpers like
    # <tt>it_should_have_many</tt>, just add them as options directly. This will use
    # <tt>with_options</tt> rather than any specific matcher helpers but will have the same
    # effects. Example:
    # 
    #   describe User do
    #     it_should_have_many :sites, :through => :memberships
    #   end
    class AssociationMatcher
      def initialize(associated, macro) # :nodoc:
        @associated = associated
        @macro = macro
        @options = {}
      end

      def matches?(main_model) # :nodoc:
        unless main_model.respond_to?(:reflect_on_association)
          if main_model.class.respond_to?(:reflect_on_association)
            main_model = main_model.class
          else
            @not_model = main_model
            return false
          end
        end
        if @association = main_model.reflect_on_association(@associated)
          @options.all?{|k, v| @association.options[k] == v ||
            [@association.options[k]] == v} # Stupid to_a being obsoleted!
        end
      end

      def failure_message # :nodoc:
        if @not_model
          " expected: #{@not_model} to be a subclass of ActiveRecord::Base class, but was not"
        elsif @association
          " expected: #{association_with(@options)}\n      got: #{association_with(@association.options)}"
        else
          " expected: #{association_with(@options)}, but the association does not exist"
        end
      end

      def negative_failure_message # :nodoc:
        if @association
          " expected: #{association_with(@options)}\n      got: #{association_with(@association.options)}"
        else
          " expected: #{association_with(@options)} to not occur but it does"
        end
      end

      # The following public methods are chainable extensions on the main matcher
      # Examples:
      # 
      #   Foo.should have_many(:bars).through(:foobars).with_dependent(:destroy)
      #   Bar.should belong_to(:baz).with_class_name("Unbaz")
      def through(through_model)
        @options[:through] = through_model
        self
      end

      def and_includes(included_models)
        @options[:include] = included_models
        self
      end

      def and_extends(*modules)
        @options[:extends] = modules
        self
      end

      def with_counter_cache(counter_cache = true)
        if counter_cache
          @options[:counter_cache] = counter_cache
        end
        self
      end

      def uniq(*irrelevant_args)
        @options[:uniq] = true
        self
      end
      alias and_is_unique uniq
      alias with_unique uniq

      def polymorphic(*irrelevant_args)
        @options[:polymorphic] = true
        self
      end
      alias and_is_polymorphic polymorphic
      alias with_polymorphic polymorphic

      def as(interface)
        @options[:as] = interface
      end

      # Use this to just specify the options as a hash.
      # Note: It will completely override any previously set options
      def with_options(options = {})
        options.each{|k, v| @options[k] = v}
        self
      end

    private
      # Takes care of methods like with_dependent(:destroy)
      def method_missing(method_id, *args, &block)
        method_name = method_id.to_s
        if method_name =~ /^with_(.*)/
          @options[$1.to_sym] = args
          self
        else
          super method_id, *args, &block
        end
      end

      def association_with(options)
        option_string = (options.nil? || options.empty?) ? "" : options.inspect
        unless option_string.blank?
          option_string.sub! /^\{(.*)\}$/, ', \1'
          option_string.gsub! /\=\>/, ' => '
        end
        "#{@macro} :#{@associated}#{option_string}"
      end
    end
    
    # Creates matcher that checks if the receiver has a <tt>belongs_to</tt> association
    # with the specified model.
    # 
    # <b>Note:</b> The argument should be a symbol as in the model's association definition
    # and not the model's class name.
    def belong_to(model)
      AssociationMatcher.new model, :belongs_to
    end

    # Creates matcher that checks if the receiver has a <tt>have_one</tt> association
    # with the specified model.
    # 
    # <b>Note:</b> The argument should be a symbol as in the model's association definition
    # and not the model's class name.
    def have_one(model)
      AssociationMatcher.new model, :has_one
    end

    # Creates matcher that checks if the receiver has a <tt>have_many</tt> association
    # with the specified model.
    # 
    # <b>Note:</b> The argument should be a symbol as in the model's association definition
    # and not the model's class name.
    def have_many(models)
      AssociationMatcher.new models, :has_many
    end

    # Creates matcher that checks if the receiver has a <tt>have_and_belong_to_many</tt> association
    # with the specified model.
    # 
    # <b>Note:</b> The argument should be a symbol as in the model's association definition
    # and not the model's class name.
    def have_and_belong_to_many(models)
      AssociationMatcher.new models, :has_and_belongs_to_many
    end
    
  private
    def class_or_instance
      @model_spec_class_or_instance ||= class_for(described_type) || instance
    end
    
    def instance
      @model_spec_instance ||= instance_for(described_type)
    end
    
    # These methods are designed to be used at the example group [read: "describe"] level
    # to simplify and DRY up common expectations. Some of these methods are wrappers for
    # matchers which can also be used on the example level [read: within an "it" block]. See
    # LuckySneaks::ModelSpecHelpers for more information.
    # 
    # <b>Note:</b> The validation matchers are only meant to be used for simple validation checking
    # not as a one-size-fits-all solution.
    module ExampleGroupLevelMethods
      # Creates an expectation that the current model being spec'd has a <tt>belong_to</tt>
      # association with the specified model. Accepts optional arguments which are appended to
      # the <tt>belong_to</tt> spec like this:
      # 
      #   it_should_belong_to :document, :counter_cache => true
      # 
      # which is the same as writing out:
      # 
      #   it "should belong to document" do
      #     Comment.should belong_to(:document).with_options(:counter_cache => true)
      #   end
      # 
      # If you want a more detailed spec description text, feel free to write this out in the long
      # form and use <tt>belong_to</tt> and its related matcher helpers.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_belong_to(model, options = {})
        it "should belong to a #{model}" do
          if options.empty?
            class_or_instance.should belong_to(model)
          else
            class_or_instance.should belong_to(model).with_options(options)
          end
        end
      end
      
      # Creates an expectation that the current model being spec'd has a <tt>have_one</tt>
      # association with the specified model. Accepts optional arguments which are appended to
      # the <tt>have_one</tt> spec like this:
      # 
      #   it_should_have_one :last_comment, :class_name => "Comment", :order => "created_at DESC"
      # 
      # which is the same as writing out:
      # 
      #   it "should have one document" do
      #     Document.should have_one(:last_comment).with_options(:class_name => "Comment", :order => "created_at DESC")
      #   end
      # 
      # If you want a more detailed spec description text, feel free to write this out in the long
      # form and use <tt>have_one</tt> and its related matcher helpers.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_have_one(model, options = {})
        it "should have one #{model}" do
          if options.empty?
            class_or_instance.should have_one(model)
          else
            class_or_instance.should have_one(model).with_options(options)
          end
        end
      end
      
      # Creates an expectation that the current model being spec'd has a <tt>have_many</tt>
      # association with the specified model. Accepts optional arguments which are appended to
      # the <tt>have_many</tt> spec like this:
      # 
      #   it_should_have_many :memberships, :through => :sites
      # 
      # which is the same as writing out:
      # 
      #   it "should have many memberships" do
      #     User.should have_many(:memberships).with_options(:through => :sites)
      #   end
      # 
      # If you want a more detailed spec description text, feel free to write this out in the long
      # form and use <tt>have_many</tt> and its related matcher helpers.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_have_many(models, options = {})
        it "should have many #{models}" do
          if options.empty?
            class_or_instance.should have_many(models)
          else
            class_or_instance.should have_many(models).with_options(options)
          end
        end
      end
      
      # Creates an expectation that the current model being spec'd has a <tt>have_and_belong_to_many</tt>
      # association with the specified model. Accepts optional arguments which are appended to
      # the <tt>have_and_belong_to_many</tt> spec like this:
      # 
      #   it_should_have_and_belong_to_many :documents, :include => :attachments
      # 
      # which is the same as writing out:
      # 
      #   it "should belong to document" do
      #     User.should have_and_belong_to_many(:documents).with_options(:include => :attachments)
      #   end
      # 
      # If you want a more detailed spec description text, feel free to write this out in the long
      # form and use <tt>have_and_belong_to_many</tt> and its related matcher helpers.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_have_and_belong_to_many(models, options = {})
        it "should have and belong to many #{models}" do
          if options.empty?
            class_or_instance.should have_and_belong_to_many(models)
          else
            class_or_instance.should have_and_belong_to_many(models).with_options(options)
          end
        end
      end
      
      # Creates an expectation that new instances of the model being spec'd 
      # should initialise the specified attributes with a default value.
      # 
      #  it_should_default_attributes :status => 'new'
      #
      def it_should_default_attributes(hash_attribute_values)
        hash_attribute_values.each_pair do |a,v|
          it "should default #{a} attribute to #{v}" do
            class_or_instance.new.send(a).should == v
          end
        end
      end
      
      # Creates an expectation that the current model being spec'd <tt>validates_presence_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      def it_should_validate_presence_of(attribute, message = default_error_message(:blank))
        it "should not be valid if #{attribute} is blank" do
          instance.send "#{attribute}=", nil
          instance.errors_on(attribute).should include(message)
        end
      end
      
      # Negative version of <tt>it_should_validate_presence_of</tt>. See that method for more
      # details. You'd probably only be using this in a nested example block to compare that
      # one scenario validates presence and another does not (because of conditions in
      # <tt>:if/:unless</tt>).
      def it_should_not_validate_presence_of(attribute, message = default_error_message(:blank))
        it "should be valid if #{attribute} is blank" do
          instance.send "#{attribute}=", nil
          instance.errors_on(attribute).should_not include(message)
        end
      end
            
      # Creates an expectation that the current model being spec'd <tt>validates_inclusion_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.     
      def it_should_validate_inclusion_of(attribute, options = {}, message = default_error_message(:inclusion))
       it "should validate #{attribute} is in #{options[:in].to_s}" do
         # We specifically do not try to go below the range on String and character ranges because that problem set is unpredictable. 
         lower  = options[:in].first.respond_to?(:-) ? options[:in].first - 0.0001 : nil
         higher = options[:in].last.succ 
         
         instance.send "#{attribute}=", lower
         instance.errors_on(attribute).should include(message)

         instance.send "#{attribute}=", higher
         instance.errors_on(attribute).should include(message)

         instance.send "#{attribute}=", (lower+higher)/2
         instance.errors_on(attribute).should_not include(message)
       end
     end

      # Creates an expectation that the current model being spec'd <tt>validates_numericality_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      def it_should_validate_numericality_of(attribute, message = default_error_message(:not_a_number))
        it "should validate #{attribute} is a numeric" do
          instance.send "#{attribute}=", "NaN"
          instance.errors_on(attribute).should include(message)
        end
      end
      
      # Negative version of <tt>it_should_validate_numericality_of</tt>. See that method for more
      # details. You'd probably only be using this in a nested example block to compare that
      # one scenario validates presence and another does not (because of conditions in
      # <tt>:if/:unless</tt>).
      def it_should_not_validate_numericality_of(attribute, message = default_error_message(:not_a_number))
        it "should not validate #{attribute} is a numeric" do
          instance.send "#{attribute}=", "NaN"
          instance.errors_on(attribute).should_not include(message)
        end
      end
      
      # Creates an expectation that the current model being spec'd <tt>validates_confirmation_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      def it_should_validate_confirmation_of(attribute, message = default_error_message(:confirmation))
        it "should validate confirmation of #{attribute}" do
          dummy_value = dummy_value_for(instance, attribute) || "try a string"
          instance.send "#{attribute}=", dummy_value
          instance.send "#{attribute}_confirmation=", dummy_value.succ
          instance.errors_on(attribute).should include(message)
        end
      end
      
      # Creates an expectation that the current model being spec'd <tt>validates_uniqueness_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      # 
      # <b>Note:</b> This method will fail completely if <tt>valid_attributes</tt>
      # does not provide all the attributes needed to create a valid record.
      def it_should_validate_uniqueness_of(attribute, message = default_error_message(:taken))
        it "should validate uniqueness of #{attribute}" do
          previous_instance = instance.class.create!(valid_attributes)
          instance.attributes = valid_attributes
          instance.errors_on(attribute).should include(message)
          previous_instance.destroy
        end
      end
      
      # Negative version of <tt>it_should_validate_uniqueness_of</tt>. See that method for more
      # details. You'd probably only be using this in a nested example block to compare that
      # one scenario validates presence and another does not (because of conditions in
      # <tt>:if/:unless</tt>).
      def it_should_not_validate_uniqueness_of(attribute, message = default_error_message(:taken))
        it "should not validate uniqueness of #{attribute}" do
          previous_instance = instance.class.create!(valid_attributes)
          instance.attributes = valid_attributes
          instance.errors_on(attribute).should_not include(message)
          previous_instance.destroy
        end
      end
      
      # Creates an expectation that the current model being spec'd accepts the specified values as
      # valid for the specified attribute. This is most likely used with <tt>validates_format_of</tt>
      # but there's nothing saying it couldn't be another validation.
      def it_should_accept_as_valid(attribute, *values)
        values.flatten.each do |value|
          value_inspect = case value
            when String : "'#{value}'"
            when NilClass : "nil"
            else value
          end
          it "should accept #{value_inspect} as a valid #{attribute}" do
            instance.send "#{attribute}=", value
            instance.errors_on(attribute).should == []
          end
        end
      end
      
      # Creates an expectation that the current model being spec'd does not accept the specified
      # values as valid for the specified attribute. This is most likely used with
      # <tt>validates_format_of</tt> but there's nothing saying it couldn't be another validation.
      # Takes an optional argument <tt>:message => "some custom error messsage"</tt> for
      # spec'ing the actual error message.
      def it_should_not_accept_as_valid(attribute, *values)
        options = values.extract_options!
        values.flatten.each do |value|
          value_inspect = case value
            when String : "'#{value}'"
            when NilClass : "nil"
            else value
          end
          it "should not accept #{value_inspect} as a valid #{attribute}" do
            instance.send "#{attribute}=", value
            if options[:message]
              instance.errors_on(attribute).should include(options[:message])
            else
              instance.should have_at_least(1).errors_on(attribute)
            end
          end
        end
      end
      
      # Creates an expectation that the current model being spec'd doesn't allow mass-assignment
      # of the specified attribute.
      def it_should_not_mass_assign(attribute)
        it "should not allow mass-assignment of #{attribute}" do
          lambda {
            instance.send :attributes=, {attribute => dummy_value_for(instance, attribute)}
          }.should_not change(instance, attribute)
        end
      end
      
      def default_error_message(attribute)
        if defined?(I18n)
          I18n.translate attribute, :scope => "activerecord.errors.messages"
        else
          ActiveRecord::Errors.default_error_messages[attribute]
        end
      end
    end
  end
end
