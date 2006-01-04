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
module ActionController #:nodoc:
  class Base
    protected
      def render_action(action_name, status = nil, with_layout = true)
        template = default_template_name(action_name)
        if with_layout && !template_exempt_from_layout?(template) 
          render_with_layout(template, status)
        else
          render_without_layout(template, status)
        end
      end

    private
      def template_exempt_from_layout?(template_name = default_template_name)
        @template.javascript_template_exists?(template_name)
      end

			def default_template_name(default_action_name = action_name)
			  default_action_name = default_action_name.dup
			  strip_out_controller!(default_action_name) if template_path_includes_controller?(default_action_name)
			  "#{self.class.controller_path}/#{default_action_name}"
      end

			def strip_out_controller!(path)
        path.replace path.split('/', 2).last
      end

      def template_path_includes_controller?(path)
        path.to_s['/'] && self.class.controller_path.split('/')[-1] == path.split('/')[0]
      end
  end

  module Layout #:nodoc:
    private
      def apply_layout?(template_with_options, options)
        template_with_options ?  candidate_for_layout?(options) : !template_exempt_from_layout?
      end

      def candidate_for_layout?(options)
        (options.has_key?(:layout) && options[:layout] != false) || 
        options.values_at(:text, :file, :inline, :partial, :nothing).compact.empty? &&
        !template_exempt_from_layout?(default_template_name(options[:action] || options[:template]))
      end
  end
end
