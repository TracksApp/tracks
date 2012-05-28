xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @feed_title
    xml.description @feed_description
    xml.link contexts_url
    xml.language 'en-us'
    xml.ttl 40

    @all_contexts.each do |context|
      xml.item do
        xml.title h(context.title)
        xml.description context_summary(context, count_undone_todos_phrase(context))
        xml.pubDate context.created_at.to_s(:rfc822)
        xml.link context_url(context)
        xml.guid context_url(context)
      end
    end
  end
end
