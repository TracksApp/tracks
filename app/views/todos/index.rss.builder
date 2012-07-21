xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @feed_title
    xml.description @feed_description
    xml.link todos_url
    xml.language 'en-us'
    xml.ttl 40

    @todos.each do |todo|
      xml.item do
        xml.title h(todo.description)
        xml.description feed_content_for_todo(todo)
        xml.pubDate todo.created_at.to_s(:rfc822)
        xml.link (todo.project && !todo.project.is_a?(NullProject)) ? project_url(todo.project) : context_url(todo.context)
        xml.guid todo_url(todo)
      end
    end
  end
end