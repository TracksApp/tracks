require 'active_support/all'

class Staleness
  SECONDS_PER_DAY = 86400

  def self.days_stale(item, current_user)
    return 0 if cannot_be_stale(item, current_user)
    (UserTime.new(current_user).time.utc - item.created_at.utc).to_i / SECONDS_PER_DAY
  end

  def self.cannot_be_stale(item, current_user)
    return true if item.due || item.completed?
    return true if item.created_at > UserTime.new(current_user).time
    false
  end
end

