module SeleniumOnRails::Renderer
  include SeleniumOnRails::Paths
  include SeleniumHelper
  
  def render_test_case filename
    @template.extend SeleniumOnRails::PartialsSupport
    @page_title = test_case_name filename
    output = render_to_string :file => filename
    layout = (output =~ /<html>/i ? false : layout_path)
    render :text => output, :layout => layout

    headers['Cache-control'] = 'no-cache'
    headers['Pragma'] = 'no-cache'
    headers['Expires'] = '-1'
  end

end