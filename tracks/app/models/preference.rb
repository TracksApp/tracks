class Preference < ActiveRecord::Base
  belongs_to :user
  
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