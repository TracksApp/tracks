ActiveRecord::Validations::ClassMethods.class_eval do 
# Custom validations

# Validating a date field parsed by Chronic. If Chronic cannot parse the
# date, it returns nil
# Adapted from Stuart Rackham's custom date validation
# http://www.bigbold.com/snippets/posts/show/1548
#
def validates_chronic_date(*attr_names)
  configuration =
    { :message => 'is an invalid date. Here are some valid examples: feb 23, 23 feb 06, 6 feb 2006, 2006-02-23, tomorrow, today, 5 days (hence), 1 month hence, etc.)',
      :on => :save,
    }
  configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
  # Don't let validates_each handle allow_nils, it checks the cast value.
  allow_nil = configuration.delete(:allow_nil)
  validates_each(attr_names, configuration) do |record, attr_name, value|
    before_cast = record.send("#{attr_name}_before_type_cast")
    next if allow_nil and (before_cast == '')
    begin
      date = Chronic.parse(before_cast.to_s).nil?
    rescue
      record.errors.add(attr_name, configuration[:message])
    end
  end
end

end