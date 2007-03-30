module ActionView::Helpers::TagHelper
  include UJS::Helpers
  
  JAVASCRIPT_EVENTS = %w(click mouseup mousedown dblclick mousemove mouseover mouseout submit change keypress keyup keydown load)
  
  alias_method :rails_tag_options, :tag_options

  protected
    # Patch to the built-in Rails tag_options method. Looks for any
    # javascript event handlers, extracts them and registers them
    # as unobtrusive behaviours.
    #
    # This behaviour affects any built-in Rails helpers that generate
    # HTML. Event extraction behaviour can be bypassed by passing in
    # <tt>:inline => true</tt> as part of a helper's HTML options hash.
    def tag_options(opts)
      set_default_external!(opts)
      if opts[:external]
        JAVASCRIPT_EVENTS.each do |event|
          unless opts["on#{event}"].blank?
            opts['id'] = generate_html_id unless opts['id']
            apply_behaviour("##{opts['id']}:#{event}", opts["on#{event}"]) unless opts["on#{event}"].nil?
            opts.delete("on#{event}")
          end
        end
        opts.delete(:external)
      end
      rails_tag_options(opts)
    end

    # Generate a unique id to be used as the HTML +id+ attribute.
    def generate_html_id
      @tag_counter ||= 0
      @tag_counter = @tag_counter.next
      "#{UJS::Settings.generated_id_prefix}#{@tag_counter}"
    end
end