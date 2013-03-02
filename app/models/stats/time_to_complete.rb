module Stats
  class TimeToComplete

    SECONDS_PER_DAY = 86400;

    attr_reader :actions
    def initialize(actions)
      @actions = actions
    end

    def avg
      @avg ||= (sum / count) / SECONDS_PER_DAY
    end

    def max
      @max ||= max_in_seconds / SECONDS_PER_DAY
    end

    def min
      @min ||= min_in_seconds / SECONDS_PER_DAY
    end

    def min_sec
      min_sec = arbitrary_day + min_in_seconds # convert to a datetime
      @min_sec = min_sec.strftime("%H:%M:%S")
      @min_sec = min.round.to_s + " days " + @min_sec if min >= 1
      @min_sec
    end

    private

    def min_in_seconds
      @min_in_seconds ||= durations.min || 0
    end

    def max_in_seconds
      @max_in_seconds ||= durations.max || 0
    end

    def count
      actions.empty? ? 1 : actions.size
    end

    def durations
      @durations ||= actions.map do |r|
        (r.completed_at - r.created_at)
      end
    end

    def sum
      @sum ||= durations.inject(0) {|sum, d| sum + d}
    end

    def arbitrary_day
      @arbitrary_day ||= Time.utc(2000, 1, 1, 0, 0)
    end

  end
end
