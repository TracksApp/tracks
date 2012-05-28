atom_feed do |feed|
  feed.title(@feed_title)
  feed.subtitle(@feed_description)
  feed.updated(@projects.last.updated_at)

  @projects.each do |project|
    feed.entry(project) do |entry|
      entry.title(h(project.name))
      entry.content(project_summary(project), :type => :html)
    end
  end
end