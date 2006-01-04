#--
# Copyright (c) 2004 David Heinemeier Hansson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module ActionView
  class Base
    def pick_template_extension(template_path)#:nodoc:
      if match = delegate_template_exists?(template_path)
        match.first
      elsif erb_template_exists?(template_path):        'rhtml'
      elsif builder_template_exists?(template_path):    'rxml'
      elsif javascript_template_exists?(template_path): 'rjs'
      else
        raise ActionViewError, "No rhtml, rxml, rjs or delegate template found for #{template_path}"
      end
    end

    def javascript_template_exists?(template_path)#:nodoc:
      template_exists?(template_path, :rjs)
    end

    def file_exists?(template_path)#:nodoc:
        %w(erb builder javascript delegate).any? do |template_type|
        send("#{template_type}_template_exists?", template_path)
      end
    end

    private
      # Create source code for given template
      def create_template_source(extension, template, render_symbol, locals)
        if template_requires_setup?(extension)
          body = case extension.to_sym
            when :rxml
              "xml = Builder::XmlMarkup.new(:indent => 2)\n" +
              "@controller.headers['Content-Type'] ||= 'text/xml'\n" +
              template
            when :rjs
              "@controller.headers['Content-Type'] ||= 'text/javascript'\n" +
              "update_page do |page|\n#{template}\nend"
            end
        else
          body = ERB.new(template, nil, @@erb_trim_mode).src
        end

        @@template_args[render_symbol] ||= {}
        locals_keys = @@template_args[render_symbol].keys | locals
        @@template_args[render_symbol] = locals_keys.inject({}) { |h, k| h[k] = true; h }

        locals_code = ""
        locals_keys.each do |key|
          locals_code << "#{key} = local_assigns[:#{key}] if local_assigns.has_key?(:#{key})\n"
        end

        "def #{render_symbol}(local_assigns)\n#{locals_code}#{body}\nend"
      end

      def template_requires_setup?(extension)
        templates_requiring_setup.include? extension.to_s
      end

      def templates_requiring_setup
        %w(rxml rjs)
      end

      def assign_method_name(extension, template, file_name)
        method_name = '_run_'
        method_name << "#{extension}_" if extension

        if file_name
          file_path = File.expand_path(file_name)
          base_path = File.expand_path(@base_path)

          i = file_path.index(base_path)
          l = base_path.length

          method_name_file_part = i ? file_path[i+l+1,file_path.length-l-1] : file_path.clone
          method_name_file_part.sub!(/\.r(html|xml|js)$/,'')
          method_name_file_part.tr!('/:-', '_')
          method_name_file_part.gsub!(/[^a-zA-Z0-9_]/){|s| s[0].to_s}

          method_name += method_name_file_part
        else
          @@inline_template_count += 1
          method_name << @@inline_template_count.to_s
        end

        @@method_names[file_name || template] = method_name.intern
      end

      def compile_template(extension, template, file_name, local_assigns)
        method_key = file_name || template

        render_symbol = @@method_names[method_key] || assign_method_name(extension, template, file_name)
        render_source = create_template_source(extension, template, render_symbol, local_assigns.keys)

        line_offset = @@template_args[render_symbol].size
        if extension
          case extension.to_sym
          when :rxml, :rjs
            line_offset += 2
          end
        end
        
        begin
          unless file_name.blank?
            CompiledTemplates.module_eval(render_source, file_name, -line_offset)
          else
            CompiledTemplates.module_eval(render_source, 'compiled-template', -line_offset)
          end
        rescue Object => e
          if logger
            logger.debug "ERROR: compiling #{render_symbol} RAISED #{e}"
            logger.debug "Function body: #{render_source}"
            logger.debug "Backtrace: #{e.backtrace.join("\n")}"
          end

          raise TemplateError.new(@base_path, method_key, @assigns, template, e)
        end

        @@compile_time[render_symbol] = Time.now
        # logger.debug "Compiled template #{method_key}\n  ==> #{render_symbol}" if logger
      end
  end
end
