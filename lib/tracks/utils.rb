require 'redcloth'

module Tracks

  class Utils
    AUTO_LINK_MESSAGE_RE = %r{message://<[^>]+>} unless const_defined?(:AUTO_LINK_MESSAGE_RE)
  
    # Converts message:// links to href. This URL scheme is used on Mac OS X
    # to link to a mail message in Mail.app.
    def self.auto_link_message(text)
      text.gsub(AUTO_LINK_MESSAGE_RE) do
        href = $&
        left, right = $`, $'
        # detect already linked URLs and URLs in the middle of a tag
        if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
          # do not change string; URL is alreay linked
          href
        else
          content = helpers.content_tag(:a, h(href), :href => h(href))
        end
      end
    end

    def self.render_text(text)
      rendered = Tracks::Utils.auto_link_message(text)
      rendered = markdown(rendered)
      rendered = helpers.auto_link(rendered, :link => :urls)

      # add onenote and message protocols
      Sanitize::Config::RELAXED[:protocols]['a']['href'] << 'onenote'
      Sanitize::Config::RELAXED[:protocols]['a']['href'] << 'message'
  
      rendered = Sanitize.clean(rendered, Sanitize::Config::RELAXED)
      return rendered.html_safe
    end
    
    # Uses RedCloth to transform text using either Textile or Markdown Need to
    # require redcloth above RedCloth 3.0 or greater is needed to use Markdown,
    # otherwise it only handles Textile
    #
    def self.markdown(text)
      RedCloth.new(text).to_html
    end
    
    private
    
    def self.helpers
      ActionController::Base.helpers
    end
    
  end
  
end