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
  module Helpers
    module JavaScriptHelper
      # JavaScriptGenerator generates blocks of JavaScript code that allow you 
      # to change the content and presentation of multiple DOM elements.  Use 
      # this in your Ajax response bodies, either in a <script> tag or as plain
      # JavaScript sent with a Content-type of "text/javascript".
      #
      # Create new instances with PrototypeHelper#update_page, then call 
      # #insert_html, #replace_html, #remove, #show, or #hide on the yielded
      # generator in any order you like to modify the content and appearance of
      # the current page.  (You can also call other helper methods which
      # return JavaScript, such as 
      # ActionView::Helpers::ScriptaculousHelper#visual_effect.)
      #
      # Example:
      #
      #   update_page do |page|
      #     page.insert_html :bottom, 'list', '<li>Last item</li>'
      #     page.visual_effect :highlight, 'list'
      #     page.hide 'status-indicator', 'cancel-link'
      #   end
      # 
      # generates the following JavaScript:
      #
      #   new Insertion.Bottom("list", "<li>Last item</li>");
      #   new Effect.Highlight("list");
      #   ["status-indicator", "cancel-link"].each(Element.hide);
      #
      # You can also use PrototypeHelper#update_page_tag instead of 
      # PrototypeHelper#update_page to wrap the generated JavaScript in a
      # <script> tag.
      class JavaScriptGenerator
        def initialize(context) #:nodoc:
          @context, @lines = context, []
          yield self
        end
  
        def to_s #:nodoc:
          @lines * $/
        end
  
        # Inserts HTML at the specified +position+ relative to the DOM element
        # identified by the given +id+.
        # 
        # +position+ may be one of:
        # 
        # <tt>:top</tt>::    HTML is inserted inside the element, before the 
        #                    element's existing content.
        # <tt>:bottom</tt>:: HTML is inserted inside the element, after the
        #                    element's existing content.
        # <tt>:before</tt>:: HTML is inserted immediately preceeding the element.
        # <tt>:after</tt>::  HTML is inserted immediately following the element.
        #
        # +options_for_render+ may be either a string of HTML to insert, or a hash
        # of options to be passed to ActionView::Base#render.  For example:
        #
        #   # Insert the rendered 'navigation' partial just before the DOM
        #   # element with ID 'content'.
        #   insert_html :before, 'content', :partial => 'navigation'
        #
        #   # Add a list item to the bottom of the <ul> with ID 'list'.
        #   insert_html :bottom, 'list', '<li>Last item</li>'
        #
        def insert_html(position, id, *options_for_render)
          insertion = position.to_s.camelize
          call "new Insertion.#{insertion}", id, render(*options_for_render)
        end
  
        # Replaces the inner HTML of the DOM element with the given +id+.
        #
        # +options_for_render+ may be either a string of HTML to insert, or a hash
        # of options to be passed to ActionView::Base#render.  For example:
        #
        #   # Replace the HTML of the DOM element having ID 'person-45' with the
        #   # 'person' partial for the appropriate object.
        #   replace_html 'person-45', :partial => 'person', :object => @person
        #
        def replace_html(id, *options_for_render)
          call 'Element.update', id, render(*options_for_render)
        end
  
        # Removes the DOM elements with the given +ids+ from the page.
        def remove(*ids)
          record "#{javascript_object_for(ids)}.each(Element.remove)"
        end
  
        # Shows hidden DOM elements with the given +ids+.
        def show(*ids)
          call 'Element.show', *ids
        end
  
        # Hides the visible DOM elements with the given +ids+.
        def hide(*ids)
          call 'Element.hide', *ids
        end

				# Toggles the visibility of the DOM elements with the given +ids+. 
				def toggle(*ids) 
				  call 'Element.toggle', *ids 
				end
        
        # Displays an alert dialog with the given +message+.
        def alert(message)
          call 'alert', message
        end
        
        # Redirects the browser to the given +location+, in the same form as
        # +url_for+.
        def redirect_to(location)
          assign 'window.location.href', @context.url_for(location)
        end
        
        # Calls the JavaScript +function+, optionally with the given 
        # +arguments+.
        def call(function, *arguments)
          record "#{function}(#{arguments_for_call(arguments)})"
        end
        
        # Assigns the JavaScript +variable+ the given +value+.
        def assign(variable, value)
          record "#{variable} = #{javascript_object_for(value)}"
        end
        
        # Writes raw JavaScript to the page.
        def <<(javascript)
          @lines << javascript
        end

				# Executes the content of the block after a delay of +seconds+. Example: 
        # 
        #   page.delay(20) do 
        #     page.visual_effect :fade, 'notice' 
        #   end 
        def delay(seconds = 1) 
          record "setTimeout(function() {\n\n" 
          yield 
          record "}, #{(seconds * 1000).to_i})" 
        end 
        
      private
        def method_missing(method, *arguments, &block)
          record(@context.send(method, *arguments, &block))
        end

        def record(line)
          returning line = "#{line.to_s.chomp.gsub /\;$/, ''};" do
            self << line
          end
        end
  
        def render(*options_for_render)
          Hash === options_for_render.first ? 
            @context.render(*options_for_render) : 
              options_for_render.first.to_s
        end

        def javascript_object_for(object)
          object.respond_to?(:to_json) ? object.to_json : object.inspect
        end

        def arguments_for_call(arguments)
          arguments.map { |argument| javascript_object_for(argument) }.join ', '
        end
      end
      
      # Yields a JavaScriptGenerator and returns the generated JavaScript code.
      # Use this to update multiple elements on a page in an Ajax response.
      # See JavaScriptGenerator for more information.
      def update_page(&block)
        JavaScriptGenerator.new(@template, &block).to_s
      end
      
      # Works like update_page but wraps the generated JavaScript in a <script>
      # tag. Use this to include generated JavaScript in an ERb template.
      # See JavaScriptGenerator for more information.
      def update_page_tag(&block)
        javascript_tag update_page(&block)
      end
    end
  end
end
