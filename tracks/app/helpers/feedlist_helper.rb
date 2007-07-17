module FeedlistHelper
  
  def rss_formatted_link(options = {})
    image_tag = image_tag("feed-icon.png", :size => "16X16", :border => 0, :class => "rss-icon")
    linkoptions = { :token => @user.token, :format => 'rss' }
    linkoptions.merge!(options)
		link_to(image_tag, linkoptions, :title => "RSS feed")
  end

  def text_formatted_link(options = {})
    linkoptions = { :token => @user.token, :format => 'txt' }
    linkoptions.merge!(options)
    link_to('<span class="feed">TXT</span>', linkoptions, :title => "Plain text feed" )
  end
  
  def ical_formatted_link(options = {})
    linkoptions = { :token => @user.token, :format => 'ics' }
    linkoptions.merge!(options)
    link_to('<span class="feed">iCal</span>', linkoptions, :title => "iCal feed" )
  end
  
end
