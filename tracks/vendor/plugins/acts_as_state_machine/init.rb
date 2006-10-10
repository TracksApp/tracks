require 'acts_as_state_machine'

ActiveRecord::Base.class_eval do
  include RailsStudio::Acts::StateMachine
end
