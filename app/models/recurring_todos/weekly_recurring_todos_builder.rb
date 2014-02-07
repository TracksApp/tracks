module RecurringTodos

  class WeeklyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes, WeeklyRepeatPattern)
    end

    def attributes_to_filter
      %w{weekly_selector weekly_every_x_week} + %w{monday tuesday wednesday thursday friday saturday sunday}.map{|day| "weekly_return_#{day}" }
    end

    def map_attributes(mapping)
      mapping = map(mapping, :every_other1, 'weekly_every_x_week')

      { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 0 }.each{|day, index| mapping = map_day(mapping, :every_day, "weekly_return_#{day}", index)}

      mapping
    end

    def map_day(mapping, key, source_key, index)
      mapping[key]        ||= '       ' # avoid nil
      mapping[source_key] ||= ' '       # avoid nil

      mapping[key] = mapping[key][0, index] + mapping[source_key] + mapping[key][index+1, mapping[key].length]
      mapping
    end

    def selector_key
      nil
    end

    def valid_selector?(key)
      true
    end

  end

end