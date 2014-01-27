module RecurringTodos

  class WeeklyRepeatPattern < AbstractRepeatPattern

    def initialize(user, attributes)
      super user, attributes
    end

    def mapped_attributes
      mapping = @attributes

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

  end
  
end