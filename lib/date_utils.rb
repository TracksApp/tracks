class DateUtils
  def self.midnight_for(prefs, date)
    ActiveSupport::TimeZone[prefs.time_zone].local(date.year, date.month, date.day, 0, 0, 0)
  end
end
