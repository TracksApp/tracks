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

class SeleniumOnRails::RSelenese < SeleniumOnRails::TestBuilder
  attr_accessor :view

  def initialize view
    super view
    @view = view
  end

  def render template, local_assigns
    title = (@view.assigns['page_title'] or local_assigns['page_title'])
    table(title) do
      test = self #to enable test.command

      assign_locals_code = ''
      local_assigns.each_key {|key| assign_locals_code << "#{key} = local_assigns[#{key.inspect}];"}

      eval assign_locals_code + "\n" + template.source
    end
  end
  
  def self.call(template)
    "#{name}.new(self).render(template, local_assigns)"
  end
end
