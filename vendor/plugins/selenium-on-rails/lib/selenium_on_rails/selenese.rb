require 'selenium_on_rails/partials_support'

class SeleniumOnRails::Selenese
end
ActionView::Template.register_template_handler 'sel', SeleniumOnRails::Selenese


class SeleniumOnRails::Selenese  
  def initialize view
    @view = view
  end

  def render template, local_assigns = {}
    name = (@view.assigns['page_title'] or local_assigns['page_title'])
    lines = template.source.strip.split "\n"
    html = ''
    html << extract_comments(lines)
    html << extract_commands(lines, name)
    html << extract_comments(lines)
    raise 'You cannot have comments in the middle of commands!' if next_line lines, :any
    html
  end
  
  private
    def next_line lines, expects
      while lines.any?
        l = lines.shift.strip
        next if (l.empty? and expects != :comment)
        comment = (l =~ /^\|.*\|$/).nil?
        if (comment and expects == :command) or (!comment and expects == :comment)
          lines.unshift l
          return nil
        end
        return l
      end
    end
    
    def self.call(template)
      "#{name}.new(self).render(template, local_assigns)"
    end

    def extract_comments lines
      comments = ''
      while (line = next_line lines, :comment)
        comments << line + "\n"
      end
      if defined? RedCloth
        comments = RedCloth.new(comments).to_html
      end
      comments += "\n" unless comments.empty?
      comments
    end

    def extract_commands lines, name
      html = "<table>\n<tr><th colspan=\"3\">#{name}</th></tr>\n"
      while (line = next_line lines, :command)
        line = line[1..-2] #remove starting and ending |
        cells = line.split '|'
        if cells.first == 'includePartial'
          html << include_partial(cells[1..-1])
          next
        end
        raise 'There might only be a maximum of three cells!' if cells.length > 3
        html << '<tr>'
        (1..3).each do
          cell = cells.shift
          cell = (cell ? CGI.escapeHTML(cell.strip) : '&nbsp;')
          html << "<td>#{cell}</td>"
        end
        html << "</tr>\n"
      end
      html << "</table>\n"
    end

    def include_partial params
      partial = params.shift
      locals = {}
      params.each do |assignment|
        next if assignment.empty?
        _, var, value = assignment.split(/^([a-z_][a-zA-Z0-9_]*)\s*=\s*(.*)$/)
        raise "Invalid format '#{assignment}'. Should be '|includePartial|partial|var1=value|var2=value|." unless var
        locals[var.to_sym] = value or ''
      end
      @view.render :partial => partial, :locals => locals
    end

end