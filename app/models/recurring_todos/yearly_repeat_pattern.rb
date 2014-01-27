module RecurringTodos

  class YearlyRepeatPattern < AbstractRepeatPattern

    def initialize(user, attributes)
      super user, attributes
      @selector = get_selector('yearly_selector')
    end

    def mapped_attributes
      mapping = @attributes

      mapping[:recurrence_selector] = get_recurrence_selector

      mapping[:every_other2] = mapping[get_every_other2]
      mapping = mapping.except('yearly_month_of_year').except('yearly_month_of_year2')

      mapping = map(mapping, :every_other1, 'yearly_every_x_day')
      mapping = map(mapping, :every_other3, 'yearly_every_xth_day')
      mapping = map(mapping, :every_count,  'yearly_day_of_week')

      mapping
    end

    private

    def get_recurrence_selector
      @selector=='yearly_every_x_day' ? 0 : 1
    end  

    def get_every_other2
      case get_recurrence_selector
      when 0 
        'yearly_month_of_year'
      when 1
        'yearly_month_of_year2'
      end
    end

    def valid_selector?(selector)
      %w{yearly_every_x_day yearly_every_xth_day}.include?(selector)
    end

  end
  
end