require 'active_support/time_with_zone'

module TracksCli

  class TracksXmlBuilder

    def xml_for_description(description)
      "<description>#{description}</description>"
    end

    def xml_for_project_id(project_id)
      "<project_id>#{project_id}</project_id>"
    end

    def xml_for_show_from(show_from)
      show_from.nil? ? "" : "<show-from type=\"datetime\">#{Time.at(show_from).xmlschema}</show-from>"
    end

    def xml_for_notes(notes)
      notes.nil? ? "" : "<notes>#{notes}</notes>"
    end

    def xml_for_taglist(taglist)
      unless taglist.nil?
        tags = taglist.split(",")
        if tags.length() > 0
          tags = tags.collect { |tag| "<tag><name>#{tag.strip}</name></tag>" unless tag.strip.empty?}.join('')
          return "<tags>#{tags}</tags>"
        end
      else
        return ""
      end
    end

    def xml_for_context(context_name, context_id)
      if context_name && !context_name.empty?
        return "<context><name>#{context_name}</name></context>"
      else
        return "<context_id>#{context_id}</context_id>"
      end
    end

    def xml_for_predecessor(dependend, predecessor)
      dependend ? "<predecessor_dependencies><predecessor>#{predecessor}</predecessor></predecessor_dependencies>" : ""
    end

    def build_todo_xml(todo)
      props = [
        xml_for_description(todo[:description]),
        xml_for_project_id(todo[:project_id]),
        xml_for_show_from(todo[:show_from]),
        xml_for_notes(todo[:notes]),
        xml_for_taglist(todo[:taglist]),
        xml_for_context(todo[:context_name], todo[:context_id]),
        xml_for_predecessor(todo[:is_dependend], todo[:predecessor])
      ]

      "<todo>#{props.join("")}</todo>"
    end

    def build_project_xml(project)
      "<project><name>#{project[:description]}</name><default-context-id>#{project[:default_context_id]}</default-context-id></project>"
    end

  end
end