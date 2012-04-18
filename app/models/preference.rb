class Preference < ActiveRecord::Base
  belongs_to :user
  belongs_to :sms_context, :class_name => 'Context'

  attr_accessible :date_format, :week_starts, :show_number_completed, :show_completed_projects_in_sidebar,
    :show_hidden_contexts_in_sidebar, :staleness_starts, :due_style, :admin_email
  
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

    user.at_midnight(date)
  end
end
