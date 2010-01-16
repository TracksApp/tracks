# Renders Selenium test templates in a fashion analogous to +rxml+ and
# +rjs+ templates.
#
#   setup
#   open :controller => 'customer', :action => 'list'
#   assert_title 'Customers'
#
# See SeleniumOnRails::TestBuilder for a list of available commands.
class SeleniumOnRails::RSelenese < SeleniumOnRails::TestBuilder
end
ActionView::Template.register_template_handler 'rsel', SeleniumOnRails::RSelenese

class SeleniumOnRails::RSelenese
  attr_accessor :view

  def initialize view
    super view
    @view = view
  end

  def render template, local_assigns = {}
    title = (@view.assigns['page_title'] or local_assigns['page_title'])

    evaluator = Evaluator.new(@view)
    evaluator.run_script title, assign_locals_code_from(local_assigns) + "\n" + template.source, local_assigns
  end
  
  def assign_locals_code_from(local_assigns)
    return local_assigns.keys.collect {|key| "#{key} = local_assigns[#{key.inspect}];"}.join
  end
  
  def self.call(template)
    "#{name}.new(self).render(template, local_assigns)"
  end

  class Evaluator < SeleniumOnRails::TestBuilder
    def run_script(title, script, local_assigns)
      table(title) do
        test = self #to enable test.command
        eval script
      end 
    end
  end
end
