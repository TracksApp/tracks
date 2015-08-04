module StatsHelper

  def font_size(cloud, tag)
    9 + 2 * cloud.relative_size(tag)
  end

  def month_and_year_label(i)
    t('date.month_names')[ (Time.zone.now.mon - i -1 ) % 12 + 1 ]+ " " + (Time.zone.now - i.months).year.to_s
  end

  def array_of_month_and_year_labels(count)
    Array.new(count) { |i| month_and_year_label(i) }
  end

  def month_label(i)
    t('date.month_names')[ (Time.zone.now.mon - i -1 ) % 12 + 1 ]
  end

  def array_of_month_labels(count)
    Array.new(count) { |i| month_label(i) }
  end

end
