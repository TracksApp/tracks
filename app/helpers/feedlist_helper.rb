module FeedlistHelper
  
  def rss_formatted_link(options = {})
    image_tag = image_tag("feed-icon.png", :size => "16X16", :border => 0, :class => "rss-icon")
    linkoptions = merge_hashes( {:format => 'rss'}, user_token_hash, options)
		link_to(image_tag, linkoptions, :title => "RSS feed")
  end

  def text_formatted_link(options = {})
    linkoptions = merge_hashes( {:format => 'txt'}, user_token_hash, options)
    link_to('<span class="feed">TXT</span>', linkoptions, :title => "Plain text feed" )
  end
  
  def ical_formatted_link(options = {})
    linkoptions = merge_hashes( {:format => 'ics'}, user_token_hash, options)
    link_to('<span class="feed">iCal</span>', linkoptions, :title => "iCal feed" )
  end

  def feed_links(feeds, link_options, title)
    space = " "
    html = ""
    html << rss_formatted_link(link_options)+space if feeds.include?(:rss)
    html << text_formatted_link(link_options)+space if feeds.include?(:txt)
    html << ical_formatted_link(link_options)+space if feeds.include?(:ical)
    html << title
    return html
  end

  def all_feed_links_for_project(project)
    feed_links([:rss, :txt, :ical], { :controller=> 'todos', :action => 'index', :project_id => project.to_param }, content_tag(:strong, project.name))
  end

  def all_feed_links_for_context(context)
    feed_links([:rss, :txt, :ical], { :controller=> 'todos', :action => 'index', :context_id => context.to_param }, content_tag(:strong, context.name))
  end

  protected

  def merge_hashes(*hashes)
    hashes.inject(Hash.new){ |result, h| result.merge(h) }
  end

  def user_token_hash
    { :token => current_user.token }
  end
    
end
