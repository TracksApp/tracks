module RenderingHelper
  AUTO_LINK_MESSAGE_RE = %r{message://<[^>]+>} unless const_defined?(:AUTO_LINK_MESSAGE_RE)

  # Converts message:// links to href. This URL scheme is used on Mac OS X
  # to link to a mail message in Mail.app.
  def auto_link_message(text)
    text.gsub(AUTO_LINK_MESSAGE_RE) do
      href = $&
      left = $`
      right = $'
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is already linked
        href
      else
        content_tag(:a, h(href), :href => h(href))
      end
    end
  end

  def render_text(text)
    rendered = auto_link_message(text)
    rendered = textile(rendered)
    rendered = auto_link(rendered, link: :urls, html: {target: '_blank'})

    relaxed_config = Sanitize::Config::RELAXED
    config = relaxed_config

    # add onenote and message protocols, allow a target
    a_href_config = relaxed_config[:protocols]['a']['href'] + %w(onenote message)
    a_attributes = relaxed_config[:attributes]['a'] + ['target']
    config = Sanitize::Config.merge(config, protocols: {'a' => {'href' => a_href_config}}, :attributes => {'a' => a_attributes})

    rendered = Sanitize.fragment(rendered, config)
    return rendered.html_safe
  end

  def textile(text)
    RedCloth.new(text).to_html
  end
end
