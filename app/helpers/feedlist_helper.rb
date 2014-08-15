module FeedlistHelper

  def linkoptions(format, options)
    merge_hashes( {:format => format}, options, user_token_hash)
  end

  def rss_formatted_link(options = {})
    image_tag = image_tag("feed-icon.png", :size => "16X16", :border => 0, :class => "rss-icon")
    link_to(image_tag, linkoptions('rss', options), :title => "RSS feed")
  end

  def text_formatted_link(options = {})
    link_to(content_tag(:span, 'TXT', {:class => 'feed', :title => "Plain text feed"}), linkoptions('txt', options))
  end

  def ical_formatted_link(options = {})
    link_to(content_tag(:span, 'iCal', {:class=>"feed", :title => "iCal feed"}), linkoptions('ics', options))
  end

  def feed_links(feeds, link_options, title)
    space = " "
    html = ""
    html << rss_formatted_link(link_options) +space if feeds.include?(:rss)
    html << text_formatted_link(link_options)+space if feeds.include?(:txt)
    html << ical_formatted_link(link_options)+space if feeds.include?(:ical)
    html << title
    return html.html_safe
  end

  def all_feed_links(object, symbol)
    feed_links([:rss, :txt, :ical], { :controller=> 'todos', :action => 'index', symbol => object.to_param }, content_tag(:strong, object.name))
  end

  def all_feed_links_for_project(project)
    all_feed_links(project, :project_id)
  end

  def all_feed_links_for_context(context)
    all_feed_links(context, :context_id)
  end

  protected

  def merge_hashes(*hashes)
    hashes.inject(Hash.new){ |result, h| result.merge(h) }
  end

  def user_token_hash
    { :token => current_user.token }
  end


end
