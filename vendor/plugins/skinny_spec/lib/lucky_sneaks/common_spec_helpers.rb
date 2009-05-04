module LuckySneaks
  # These methods are mostly just called internally by various other spec helper
  # methods but you're welcome to use them as needed in your own specs.
  module CommonSpecHelpers
    # Stubs out Time.now and returns value to use when comparing it. Example:
    # 
    #   time_now = stub_time_now
    #   @foo.some_method_that_resets_updated_at
    #   @foo.updated_at.should == time_now
    def stub_time_now
      returning Time.now do |now|
        Time.stub!(:now).and_return(now)
      end
    end
    
    # Returns class for the specified name. Example:
    # 
    #   class_for("foo") # => Foo
    def class_for(name)
      name.to_s.constantize
    rescue NameError
      name.to_s.pluralize.classify.constantize
      # Let any other error rise!
    end

    # Returns instance variable for the specified name. Example:
    # 
    #   instance_for("foo") # => @foo
    def instance_for(name)
      instance_variable_get("@#{name.to_s.underscore}")
    end
    
    # Wraps a matcher that checks if the receiver contains an <tt>A</tt> element (link) 
    # whose <tt>href</tt> attribute is set to the specified path.
    def have_link_to(path)
      have_tag("a[href='#{path}']")
    end
    
    # Returns dummy value for specified attribute based on the datatype expected for that
    # attribute.
    def dummy_value_for(instance, attribute)
      if datatype = instance.column_for_attribute(attribute)
        actual = instance.send(attribute)
        case datatype.type
        when :string, :text
          actual == "foo" ? "bar" : "food"
        when :integer, :float, :decimal
          actual == 108 ? 815 : 108
        when :boolean
          actual ? false : true
        when :date, :datetime, :time, :timestamp
          actual == 1.week.ago ? 2.years.ago : 1.week.ago
        end
      end
    end
    
    # Returns class description text
    def class_description_text
      if self.class.respond_to?(:description_text)
        # Old school
        self.class.description_text
      else
        # New school
        self.class.description
      end
    end
    
    # Returns description text
    def self_description_text
      if respond_to?(:description_text)
        # Old school
        description_text
      else
        # New school
        description
      end
    end
    
    def described_type
      self.class.described_type
    end
  end
end
