class Preference < ActiveRecord::Base
  belongs_to :user
    
  def self.due_styles
    { :due_in_n_days => 0, :due_on => 1}
  end
           
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
  
  def parse_date(s)
    return nil if s.blank?
    user.at_midnight(Date.strptime(s, date_format))
  end
  
end