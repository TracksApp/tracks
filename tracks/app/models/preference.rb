class Preference < ActiveRecord::Base
  belongs_to :user
  composed_of :tz,
              :class_name => 'TimeZone',
              :mapping => %w(time_zone name)
  
  DUE_ON_DUE_STYLE = 1
  DUE_IN_N_DAYS_DUE_STYLE = 0
              
  def self.day_number_to_name_map
    { 0 => "Sunday",
		  1 => "Monday",
			2 => "Tuesday",
			3 => "Wednesday",
			4 => "Thursday",
			5 => "Friday",
			6 => "Saturday"}
  end
  
  def hide_completed_actions?
    return show_number_completed == 0
  end
  
end