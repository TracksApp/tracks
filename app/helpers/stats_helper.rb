module StatsHelper

  def font_size(cloud, tag)
    9 + 2 * cloud.relative_size(tag)
  end

end
