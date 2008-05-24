require 'digest/md5'

class UnobtrusiveJavascriptController < ActionController::Base
  skip_before_filter :initialise_js_behaviours
  skip_after_filter  :store_js_behaviours
  
  after_filter :perform_any_caching 
  after_filter :reset_js_behaviours
  
  # Renders the external javascript behaviours file
  # with the appropriate content-type.
  def generate
    headers['Content-Type'] = 'text/javascript'
    
    if js_behaviours
      generate_etag
      modified? ? render_script : render_304
    else
      render :text => "", :layout => false
    end
  end 
  
  protected
  
  def perform_any_caching
    if behaviour_caching_enabled?
      self.class.cache_page js_behaviours.to_s, request.path
    end
  end
  
  private
  
  def generate_etag
    headers['ETag'] = Digest::MD5.hexdigest(js_behaviours.to_s)
  end
  
  def modified?
    request.env['HTTP_IF_NONE_MATCH'] != headers['ETag']
  end
  
  def render_script
    render :text => js_behaviours.to_s, :layout => false
  end
  
  def render_304
    render :nothing => true, :status => 304
  end
  
  def behaviour_caching_enabled?
    js_behaviours && js_behaviours.cache?
  end
end