module ActionView::Helpers::AssetTagHelper
  alias_method :rails_javascript_include_tag, :javascript_include_tag
  
  # Adds a new option to Rails' built-in <tt>javascript_include_tag</tt>
  # helper - <tt>:unobtrusive</tt>. Works in the same way as <tt>:defaults</tt> - specifying 
  # <tt>:unobtrusive</tt> will make sure the necessary javascript
  # libraries and behaviours file +script+ tags are loaded. Will happily
  # work along side <tt>:defaults</tt>.
  #
  #  <%= javascript_include_tag :defaults, :unobtrusive %>
  #
  # This replaces the old +unobtrusive_javascript_files+ helper.
  def javascript_include_tag(*sources)
   if sources.delete :unobtrusive
     sources = sources.concat(
       ['lowpro', behaviours_url]
     ).uniq
   end
   rails_javascript_include_tag(*sources)
  end
  
  protected  
    def behaviours_url
      action_path = case @controller.request.path
        when '', '/'
          '/index'
        else
          @controller.request.path
      end
      "/behaviours#{action_path}.js"
    end
end

