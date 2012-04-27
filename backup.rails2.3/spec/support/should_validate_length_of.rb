module LuckySneaks
  module ModelSpecHelpers
    module ExampleGroupLevelMethods
      def it_should_validate_length_of(attribute, options={})
        maximum = options[:maximum] || (options[:within] || []).last   || false
        minimum = options[:minimum] || (options[:within] || []).first  || false
        raise ArgumentError unless maximum || minimum

        it "should not be valid if #{attribute} length is more than #{maximum}" do
          instance.send "#{attribute}=", 'x'*(maximum+1)
          instance.errors_on(attribute).should include(
            options[:message_too_long] || I18n.t('activerecord.errors.messages.too_long', :count => maximum)
          )
        end if maximum

        it "should not be valid if #{attribute} length is less than #{minimum}" do
          instance.send "#{attribute}=", 'x'*(minimum-1)
          instance.errors_on(attribute).should include(
            options[:message_to_short] || I18n.t('activerecord.errors.messages.too_short', :count => minimum)
          )
        end if minimum
      end
    end
  end
end
