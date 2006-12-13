module FeedlistHelper
  
  def rss_feed_link(options = {})
    image_tag = image_tag("feed-icon.png", :size => "16X16", :border => 0, :class => "rss-icon")
    linkoptions = {:controller => 'feed', :action => 'rss', :login => "#{@user.login}", :token => "#{@user.word}"}
    linkoptions.merge!(options)
		link_to(image_tag, linkoptions, :title => "RSS feed")
  end
  
  def text_feed_link(options = {})
    linkoptions = {:controller => 'feed', :action => 'text', :login => "#{@user.login}", :token => "#{@user.word}"}
    linkoptions.merge!(options)
    link_to('<span class="feed">TXT</span>', linkoptions, :title => "Plain text feed" )
  end
  
  def ical_feed_link(options = {})
    linkoptions = {:controller => 'feed', :action => 'ical', :login => "#{@user.login}", :token => "#{@user.word}"}
    linkoptions.merge!(options)
    link_to('<span class="feed">iCal</span>', linkoptions, :title => "iCal feed")
  end
  
  
end
