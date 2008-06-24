module LuckySneaks
  # These methods are mostly just called internally by various other spec helper
  # methods but you're welcome to use them as needed in your own specs.
  module CommonSpecHelpers
    # Returns class for the specified name. Example:
    # 
    #   class_for("foo") # => Foo
    def class_for(name)
      name.to_s.constantize
    rescue NameError
      name.to_s.classify.constantize
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
  end
end