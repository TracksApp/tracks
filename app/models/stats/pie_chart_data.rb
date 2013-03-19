module Stats
  class PieChartData

    attr_reader :all_totals, :alpha, :title
    def initialize(all_totals, title, alpha)
      @all_totals = all_totals
      @title = title
      @alpha = alpha
    end

    def values
      @values ||= Array.new(slices) do |i|
        chart_totals[i]['total'] * 100 / sum
      end
    end

    def labels
      @labels ||= Array.new(slices) do |i|
        chart_totals[i]['name'].truncate(15, :omission => '...')
      end
    end

    def ids
      @ids ||= Array.new(slices) do |i|
        chart_totals[i]['id']
      end
    end

    def sum
      @sum ||= totals.inject(0) do |sum, total|
        sum + total
      end
    end

    private

    def pie_cutoff
      10
    end

    def slices
      @slices ||= [all_totals.size, pie_cutoff].min
    end

    def subtotal(from, to)
      totals[from..to].inject(0) do |sum, total|
        sum + total
      end
    end

    def chart_totals
      unless @chart_totals
        @chart_totals = first_n_totals(10)
        if all_totals.size > pie_cutoff
          @chart_totals[-1] = other
        end
      end
      @chart_totals
    end

    def first_n_totals(n)
      # create a duplicate so that we don't accidentally
      # overwrite the original array
      Array.new(slices) do |i|
        {
          'name' => all_totals[i]['name'],
          'total' => all_totals[i]['total'],
          'id' => all_totals[i]['id']
        }
      end
    end

    def other
      {
        'name' => I18n.t('stats.other_actions_label'),
        'id' => -1,
        'total' => subtotal(slices-1, all_totals.size-1)
      }
    end

    def totals
      @totals ||= all_totals.map { |item| item['total'] }
    end

  end
end
