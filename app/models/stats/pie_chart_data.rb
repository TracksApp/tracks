module Stats
  class PieChartData

    attr_reader :all_actions_per_context, :values, :labels, :ids, :alpha, :title
    def initialize(all_actions_per_context, title, alpha)
      @all_actions_per_context = all_actions_per_context
      @title = title
      @alpha = alpha
    end

    def calculate
      sum = all_actions_per_context.inject(0){|sum, apc| sum + apc['total']}

      pie_cutoff=10
      size = [all_actions_per_context.size, pie_cutoff].min

      # explicitly copy contents of hash to avoid ending up with two arrays pointing to same hashes
      actions_per_context = Array.new(size){|i| {
        'name' => all_actions_per_context[i]['name'],
        'total' => all_actions_per_context[i]['total'],
        'id' => all_actions_per_context[i]['id']
      } }

      if all_actions_per_context.size > pie_cutoff
        actions_per_context[-1]['name']=I18n.t('stats.other_actions_label')
        actions_per_context[-1]['id']=-1
        size.upto(all_actions_per_context.size-1){ |i| actions_per_context[-1]['total']+=(all_actions_per_context[i]['total']) }
      end

      @values = Array.new(size){|i| actions_per_context[i]['total']*100/sum }
      @labels = Array.new(size){|i| actions_per_context[i]['name'].truncate(15, :omission => '...') }
      @ids = Array.new(size){|i| actions_per_context[i]['id']}
    end


  end
end
