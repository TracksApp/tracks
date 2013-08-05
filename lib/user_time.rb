require 'active_support/values/time_zone'

class UserTime
  attr_reader :user, :timezone

  def initialize(user)
    @user = user
    @timezone = ActiveSupport::TimeZone[user.prefs.time_zone]
  end

  def midnight(date)
    timezone.local(date.year, date.month, date.day, 0, 0, 0)
  end

  def time
    timezone.now
  end

  def date
    time.to_date
  end
end
