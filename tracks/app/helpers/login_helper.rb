module LoginHelper
  
  
  def render_errors(obj)
    return "" unless obj
    return "" unless @request.post?
    tag = String.new

    unless obj.valid?
      tag << %{<ul class="objerrors">}      
      obj.errors.each_full { |message| tag << %{<li>#{message}</li>} }
      tag << %{</ul>}
    end
    tag
  end
  
  
end