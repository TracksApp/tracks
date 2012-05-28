atom_feed do |feed|
  feed.title(@feed_title)
  feed.subtitle(@feed_description)
  feed.updated(@todos.last.updated_at)

  @todos.each do |todo|
    feed.entry(todo) do |entry|
      entry.title(h(todo.description))
      entry.link(todo.project ? project_url(todo.project) : context_url(todo.context))
      entry.content(feed_content_for_todo(todo), :type => :html)
    end
  end
end