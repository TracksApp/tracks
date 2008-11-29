$:.unshift File.join(File.dirname(__FILE__), "..")
require "skinny_spec"

module LuckySneaks
  # These methods are designed to be used in your example [read: "it"] blocks
  # to make your model specs a little more DRY. You might also be interested 
  # in checking out the example block [read: "describe"] level versions in of these
  # methods which can DRY things up even more:
  # LuckySneaks::ModelSpecHelpers::ExampleGroupLevelMethods
  # 
  # <b>Note:</b> The validation matchers are only meant to be used for simple validation checking
  # not as a one-size-fits-all solution.
  module ModelSpecHelpers
    include LuckySneaks::CommonSpecHelpers
    
    def self.included(base) # :nodoc:
      base.extend ExampleGroupLevelMethods
    end
  
    class AssociationMatcher # :nodoc:
      def initialize(associated, macro)
        @associated = associated
        @macro = macro
        @options = {}
      end

      def matches?(main_model)
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

      def failure_message
        if @not_model
          " expected: #{@not_model} to be a subclass of ActiveRecord::Base class, but was not"
        elsif @association
          " expected: #{association_with(@options)}\n      got: #{association_with(@association.options)}"
        else
          " expected: #{association_with(@options)}, but the association does not exist"
        end
      end

      def negative_failure_message
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

      def with_counter_cache(counter_cache = false)
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
      @model_spec_class_or_instance ||= class_for(self.class.description_text) || instance
    end
    
    def instance
      @model_spec_instance ||= instance_for(self.class.description_text)
    end
    
    # These methods are designed to be used at the example group [read: "describe"] level
    # to simplify and DRY up common expectations. Most of these methods are wrappers for
    # matchers which can also be used on the example level [read: within an "it" block]. See
    # LuckySneaks::ModelSpecHelpers for more information.
    module ExampleGroupLevelMethods
      # Creates an expectation that the current model being spec'd has a <tt>belongs_to</tt>
      # association with the specified model.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_belong_to(model)
        it "should belong to a #{model}" do
          class_or_instance.should belong_to(model)
        end
      end
      
      # Creates an expectation that the current model being spec'd has a <tt>have_one</tt>
      # association with the specified model.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_have_one(model)
        it "should have one #{model}" do
          class_or_instance.should have_one(model)
        end
      end
      
      # Creates an expectation that the current model being spec'd has a <tt>have_many</tt>
      # association with the specified model.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_have_many(models)
        it "should have many #{models}" do
          class_or_instance.should have_many(models)
        end
      end
      
      # Creates an expectation that the current model being spec'd has a <tt>have_and_belong_to_many</tt>
      # association with the specified model.
      # 
      # <b>Note:</b> The argument should be a symbol as in the model's association definition
      # and not the model's class name.
      def it_should_have_and_belong_to_many(models)
        it "should have and belong to many #{models}" do
          class_or_instance.should have_and_belong_to_many(models)
        end
      end
      
      # Creates an expectation that the current model being spec'd <tt>validates_presence_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      def it_should_validate_presence_of(attribute, message = I18n.translate('activerecord.errors.messages')[:blank])
        it "should not be valid if #{attribute} is blank" do
          instance.send "#{attribute}=", nil
          instance.errors_on(attribute).should include(message)
        end
      end
      
      # Creates an expectation that the current model being spec'd <tt>validates_numericality_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      def it_should_validate_numericality_of(attribute, message = I18n.translate('activerecord.errors.messages')[:not_a_number])
        it "should validate #{attribute} is a numeric" do
          instance.send "#{attribute}=", "NaN"
          instance.errors_on(attribute).should include(message)
        end
      end
      
      # Creates an expectation that the current model being spec'd <tt>validates_confirmation_of</tt>
      # the specified attribute. Takes an optional custom message to match the one in the model's
      # validation.
      def it_should_validate_confirmation_of(attribute, message = I18n.translate('activerecord.errors.messages')[:confirmation])
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
      def it_should_validate_uniqueness_of(attribute, message = I18n.translate('activerecord.errors.messages')[:taken])
        it "should validate #{attribute} confirmation" do
          previous_instance = class_for(self.class.description_text).create!(valid_attributes)
          instance.attributes = valid_attributes
          instance.errors_on(attribute).should include(message)
          previous_instance.destroy
        end
      end
      
      # Creates an expectation that the current model being spec'd accepts the specified values as
      # valid for the specified attribute. This is most likely used with <tt>validates_format_of</tt>
      # but there's nothing saying it couldn't be another validation.
      def it_should_accept_as_valid(attribute, *values)
        values.each do |value|
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
        values.each do |value|
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
    end
  end
end