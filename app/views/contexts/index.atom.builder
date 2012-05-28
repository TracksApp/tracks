atom_feed do |feed|
  feed.title(@feed_title)
  feed.subtitle(@feed_description)
  feed.updated(@all_contexts.last.updated_at)

  @all_contexts.each do |context|
    feed.entry(context) do |entry|
      entry.title(h(context.name))
      entry.content(context_summary(context, count_undone_todos_phrase(context)), :type => :html)
    end
  end
end