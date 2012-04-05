module ExtraValidations
  
  # Validates the value of the specified attribute by checking for a forbidden string
  #
  #   class Person < ActiveRecord::Base
  #     validates_does_not_contain :first_name, :string => ','
  #   end
  #
  # A string must be provided or else an exception will be raised.
  #
  # Configuration options:
  # * <tt>message</tt> - A custom error message (default is: "is invalid")
  # * <tt>string</tt> - The string to verify is not included (note: must be supplied!)
  # * <tt>on</tt> Specifies when this validation is active (default is :save, other options :create, :update)
  # * <tt>if</tt> - Specifies a method, proc or string to call to determine if the validation should
  # occur (e.g. :if => :allow_validation, or :if => Proc.new { |user| user.signup_step > 2 }).  The
  # method, proc or string should return or evaluate to a true or false value.
  def validates_does_not_contain(*attr_names)
    configuration = { :message => I18n.translate('activerecord.errors.messages')[:invalid], :on => :save, :string => nil }
    configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

    raise(ArgumentError, "A string must be supplied as the :string option of the configuration hash") unless configuration[:string].is_a?(String)

    validates_each(attr_names, configuration) do |record, attr_name, value|
      record.errors.add(attr_name, configuration[:message]) if value.to_s =~ Regexp.new(Regexp.escape(configuration[:string]))
    end
  end
  
end
