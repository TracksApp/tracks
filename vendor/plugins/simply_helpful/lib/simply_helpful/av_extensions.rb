module ActionView
  module Partials
    def render_partial_with_record_identification(partial_path, local_assigns = nil, deprecated_local_assigns = nil)
      if partial_path.is_a?(String) || partial_path.is_a?(Symbol) || partial_path.nil?
        render_partial_without_record_identification(
          partial_path, local_assigns, deprecated_local_assigns
        )
      elsif partial_path.is_a?(Array)
        if partial_path.any?
          path       = SimplyHelpful::RecordIdentifier.partial_path(partial_path.first)
          collection = partial_path
          render_partial_collection(
            path, collection, nil, local_assigns.value
          )
        else
          ""
        end
      else
        render_partial_without_record_identification(
          SimplyHelpful::RecordIdentifier.partial_path(partial_path), local_assigns, deprecated_local_assigns
        )
      end
    end
    alias_method_chain :render_partial, :record_identification
  end
end
