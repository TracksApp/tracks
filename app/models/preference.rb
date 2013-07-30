class Preference < ActiveRecord::Base
  belongs_to :user
  belongs_to :sms_context, :class_name => 'Context'

  def self.due_styles
    { :due_in_n_days => 0, :due_on => 1}
  end

  def hide_completed_actions?
    return show_number_completed == 0
  end

  def parse_date(s)
    return nil if s.blank?
    date = nil

    if s.is_a?(Time)
      date = s.in_time_zone(time_zone).to_date
    elsif s.is_a?(String)
      date = Date.strptime(s, date_format)
    else
      raise ArgumentError.new("Bad argument type:#{s.class}")
    end

    UserTime.new(user).midnight(date)
  end
end
