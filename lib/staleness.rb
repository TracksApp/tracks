require 'active_support/all'

class Staleness
  def self.days_stale(item, current_user)
    if item.due || item.completed?
      return ""
    elsif item.created_at < current_user.time - (current_user.prefs.staleness_starts * 3).days
      return " stale_l3"
    elsif item.created_at < current_user.time - (current_user.prefs.staleness_starts * 2).days
      return " stale_l2"
    elsif item.created_at < current_user.time - (current_user.prefs.staleness_starts).days
      return " stale_l1"
    else
      return ""
    end
  end
end

