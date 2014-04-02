module RecurringTodos

  class YearlyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes, YearlyRepeatPattern)
    end

    def attributes_to_filter
      %w{ yearly_selector     yearly_month_of_year  yearly_month_of_year2 
          yearly_every_x_day  yearly_every_xth_day  yearly_day_of_week    
      }
    end

    def map_attributes(mapping)
      mapping.set(:recurrence_selector, get_recurrence_selector)
      mapping.set(:every_other2,        mapping.get(get_every_other2))

      mapping = map(mapping, :every_other1, 'yearly_every_x_day')
      mapping = map(mapping, :every_other3, 'yearly_every_xth_day')
      mapping = map(mapping, :every_count,  'yearly_day_of_week')

      mapping.except(:yearly_month_of_year).except(:yearly_month_of_year2)
    end

    def selector_key
      :yearly_selector
    end

    def valid_selector?(selector)
      %w{yearly_every_x_day yearly_every_xth_day}.include?(selector.to_s)
    end

    def get_recurrence_selector
      @selector=='yearly_every_x_day' ? 0 : 1
    end  

    def get_every_other2
      { 0 => :yearly_month_of_year, 1 => :yearly_month_of_year2 }[get_recurrence_selector]
    end

  end

end