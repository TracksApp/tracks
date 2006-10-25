require 'chronic'

ActiveRecord::Base.class_eval do
  include Chronic
end