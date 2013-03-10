require 'active_support/all'

class Staleness
  SECONDS_PER_DAY = 86400
  def self.days_stale(item, current_user)
    return 0 if item.due || item.completed?
    (current_user.time - item.created_at).to_i / SECONDS_PER_DAY
  end
end

