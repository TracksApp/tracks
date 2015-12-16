module BootstrapFlashHelper
  ALERT_MAPPING = {
    :notice => :success,
    :alert => :danger,
    :error => :danger,
    :info => :info,
    :warning => :warning
  } unless const_defined?(:ALERT_MAPPING)

  def bootstrap_flash(options = {:close_button => true})
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?
      type = type.to_sym
      next unless ALERT_MAPPING.keys.include?(type)


      tag_class = options.extract!(:class)[:class]
      tag_options = {
        class: "alert fade in alert-#{ALERT_MAPPING[type]} #{tag_class}"
      }.merge(options)

      close_button = ""
      if options[:close_button]
        close_button = content_tag(:button, raw("&times;"), type: "button", class: "close", "data-dismiss" => "alert")
      end

      Array(message).each do |msg|
        text = content_tag(:div, close_button + msg, tag_options)
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
