class BundleFu::CSSUrlRewriter
  class << self
    # rewrites a relative path to an absolute path, removing excess "../" and "./"
    # rewrite_relative_path("stylesheets/default/global.css", "../image.gif") => "/stylesheets/image.gif"
    def rewrite_relative_path(source_filename, relative_url)
      relative_url = relative_url.to_s.strip.gsub(/["']/, "")
      
      return relative_url if relative_url.first == "/" || relative_url.include?("://")
      
      elements = File.join("/", File.dirname(source_filename)).gsub(/\/+/, '/').split("/")
      elements += relative_url.gsub(/\/+/, '/').split("/")
      
      index = 0
      while(elements[index])
        if (elements[index]==".") 
          elements.delete_at(index) 
        elsif (elements[index]=="..")
          next if index==0
          index-=1
          2.times { elements.delete_at(index)}
          
        else
          index+=1
        end
      end
      
      elements * "/"
    end  
  
    # rewrite the URL reference paths
    # url(../../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/active_scaffold/default/../../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/active_scaffold/../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/../images/active_scaffold/default/add.gif);
    # url('/images/active_scaffold/default/add.gif');
    def rewrite_urls(filename, content)
      content.gsub!(/url *\(([^\)]+)\)/) { "url(#{rewrite_relative_path(filename, $1)})" }
      content
    end
    
  end
end