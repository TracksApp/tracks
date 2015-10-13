xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @feed_title
    xml.description @feed_description
    xml.link projects_url
    xml.language 'en-us'
    xml.ttl 40

    @projects.each do |project|
      xml.item do
        xml.title h(project.name)
        xml.description project_summary(project)
        xml.pubDate project.created_at.rfc822
        xml.link project_url(project)
        xml.guid project_url(project)
      end
    end
  end
end
