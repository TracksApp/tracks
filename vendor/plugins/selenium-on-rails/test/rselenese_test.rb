require File.dirname(__FILE__) + '/test_helper'

class RSeleneseTest < Test::Unit::TestCase
  include ERB::Util
  
  def rselenese name, input, partial = nil, type = nil
    view = TestView.new
    view.override_partial partial, type do
      view.assigns['page_title'] = name
      view.render_template 'rsel', input
    end
  end

  def assert_rselenese expected, name, input, partial = nil, type = nil
    assert_text_equal(expected, rselenese(name, input, partial, type))
  end

  def test_empty
    expected = <<END
<table>
<tr><th colspan="3">Empty</th></tr>
</table>
END
    input = ''
    assert_rselenese expected, 'Empty', input
  end

  def assert_generates_command expected, name, *args
    expected = expected.map {|v| h(v) }
    expected << '&nbsp;' while expected.length < 3
    expected = expected.map {|v| "<td>#{v}</td>" }.join
    expected_html = <<END
<table>
<tr><th colspan="3">Selenese Commands</th></tr>
<tr>#{expected}</tr>
</table>
END
    args_str  = args.map {|a| a.inspect }.join(',')
    input = "#{name}(#{args_str})"
    assert_rselenese expected_html, 'Selenese Commands', input
  end

  def test_element_locators
    assert_generates_command %w{click aCheckbox}, :click, 'aCheckbox'
    assert_generates_command %w{click document.foo}, :click, 'document.foo'
    assert_generates_command %w{click //a}, :click, '//a'
  end

  def test_collection_arguments
    assert_generates_command ['assertAllLinks', 'link1,link2,link3'], :assert_all_links, ['link1', 'link2','link3']
    assert_generates_command ['assertAllLinks', 'link?,link?,link?'], :assert_all_links, 'link?,link?,link?'
  end

  ARG_VALUE_MAP = {
    # We can't test url_for style arguments here, because we don't have
    # a valid controller to interpret them.  See RendererTest.
    :url => '/relative/url',
    :string => '1234',
    :pattern => 'glob:J* Smith', # Also: many other formats.
    :variable => 'varname',
    :locator => 'foo',
    :script => 'script',
    :locator_and_attribute_name => [['foo', 'attribute'], 'foo@attribute'],
    :table_locator => [['table', 2, 4], 'table.2.4'],
    :coll_pattern => [[['a', "b\\", 'c,']], "a,b\\\\,c\\,"],
    :event_name => 'eventName',
    :keycode => 123,
    :option_locator => 'label=hello',
    :window_id => [[nil], 'null'],
    :timeout => 123,
    :log_level => :debug
  }

  # Call _command_ with _args_ and make sure it produces a good table.
  # If the input command doesn't 'selenize' cleanly (e.g. if the input command
  # is :do_foo and the expected result is +dofoo+ and not +doFoo+) +command+
  # can be specified as an array (e.g. +[:input_command, 'expectedResult']).
  def assert_command_works command, *args
    expected_values = args.inject([]) do |c, arg|
      v = ARG_VALUE_MAP[arg]
      if v.is_a? Array
        c << v[1]
      else
        c << v
      end
    end
    input_values = args.inject([]) do |c, arg|
      v = ARG_VALUE_MAP[arg]
      if v.is_a? Array
        c.concat v[0]
      else
        c << v
      end
    end
    input_name, expected_name  = (command.is_a?(Array) ? command : [command, SeleniumOnRails::TestBuilder.selenize(command.to_s)])
    assert_generates_command [expected_name]+expected_values, input_name.to_s, *input_values
  end

  def test_action_commands
    assert_command_works :click, :locator
    assert_command_works :click_and_wait, :locator
    assert_command_works :fire_event, :locator, :event_name
    assert_command_works :fire_event_and_wait, :locator, :event_name
    assert_command_works :key_press, :locator, :keycode
    assert_command_works :key_press_and_wait, :locator, :keycode
    assert_command_works :key_down, :locator, :keycode
    assert_command_works :key_down_and_wait, :locator, :keycode
    assert_command_works :key_up, :locator, :keycode
    assert_command_works :key_up_and_wait, :locator, :keycode
    assert_command_works :mouse_over, :locator
    assert_command_works :mouse_over_and_wait, :locator
    assert_command_works :mouse_down, :locator
    assert_command_works :mouse_down_and_wait, :locator
    assert_command_works :type, :locator, :string
    assert_command_works :type_and_wait, :locator, :string
    assert_command_works :check, :locator
    assert_command_works :check_and_wait, :locator
    assert_command_works :uncheck, :locator
    assert_command_works :uncheck_and_wait, :locator
    assert_command_works :select, :locator, :option_locator
    assert_command_works :select_and_wait, :locator, :option_locator
    assert_command_works :add_selection, :locator, :option_locator
    assert_command_works :add_selection_and_wait, :locator, :option_locator
    assert_command_works :remove_selection, :locator, :option_locator
    assert_command_works :remove_selection_and_wait, :locator, :option_locator
    assert_command_works :submit, :locator
    assert_command_works :open, :url
    assert_command_works :select_window, :window_id
    assert_command_works [:wait_for_popup, 'waitForPopUp'], :window_id, :timeout
    assert_command_works :choose_cancel_on_next_confirmation
    assert_command_works :choose_cancel_on_next_confirmation_and_wait
    assert_command_works :answer_on_next_prompt, :string
    assert_command_works :answer_on_next_prompt_and_wait, :string
    assert_command_works :go_back
    assert_command_works :refresh
    assert_command_works :close
    assert_command_works :set_context, :string
    assert_command_works :set_context, :string, :log_level
    assert_command_works :wait_for_condition, :script, :timeout
    assert_command_works :set_timeout, :timeout
    assert_command_works :wait_for_page_to_load, :timeout
  end

  def test_accessor_commands
    assert_command_works :store_alert_present, :variable
    assert_command_works :assert_alert_present
    assert_command_works :assert_alert_not_present
    assert_command_works :verify_alert_present
    assert_command_works :verify_alert_not_present
    assert_command_works :wait_for_alert_present
    assert_command_works :wait_for_alert_not_present

    assert_command_works :store_prompt_present, :variable 
    assert_command_works :assert_prompt_present
    assert_command_works :assert_prompt_not_present
    assert_command_works :verify_prompt_present
    assert_command_works :verify_prompt_not_present
    assert_command_works :wait_for_prompt_present
    assert_command_works :wait_for_prompt_not_present

    assert_command_works :store_confirmation_present, :variable 
    assert_command_works :assert_confirmation_present
    assert_command_works :assert_confirmation_not_present
    assert_command_works :verify_confirmation_present
    assert_command_works :verify_confirmation_not_present
    assert_command_works :wait_for_confirmation_present
    assert_command_works :wait_for_confirmation_not_present

    assert_command_works :store_alert, :variable
    assert_command_works :assert_alert, :pattern
    assert_command_works :assert_not_alert, :pattern
    assert_command_works :verify_alert, :pattern
    assert_command_works :verify_not_alert, :pattern
    assert_command_works :wait_for_alert, :pattern
    assert_command_works :wait_for_not_alert, :pattern

    assert_command_works :store_confirmation, :variable
    assert_command_works :assert_confirmation, :pattern
    assert_command_works :assert_not_confirmation, :pattern
    assert_command_works :verify_confirmation, :pattern
    assert_command_works :verify_not_confirmation, :pattern
    assert_command_works :wait_for_confirmation, :pattern
    assert_command_works :wait_for_not_confirmation, :pattern

    assert_command_works :store_prompt, :variable
    assert_command_works :assert_prompt, :pattern
    assert_command_works :assert_not_prompt, :pattern
    assert_command_works :verify_prompt, :pattern
    assert_command_works :verify_not_prompt, :pattern
    assert_command_works :wait_for_prompt, :pattern
    assert_command_works :wait_for_not_prompt, :pattern

    assert_command_works :store_absolute_location, :variable
    assert_command_works :assert_absolute_location, :url
    assert_command_works :assert_not_absolute_location, :url
    assert_command_works :verify_absolute_location, :url
    assert_command_works :verify_not_absolute_location, :url
    assert_command_works :wait_for_absolute_location, :url
    assert_command_works :wait_for_not_absolute_location, :url

    assert_command_works :store_location, :pattern, :variable
    assert_command_works :assert_location, :url
    assert_command_works :assert_not_location, :url
    assert_command_works :verify_location, :url
    assert_command_works :verify_not_location, :url
    assert_command_works :wait_for_location, :url
    assert_command_works :wait_for_not_location, :url
    
    assert_command_works :store_title, :variable
    assert_command_works :assert_title, :pattern
    assert_command_works :assert_not_title, :pattern
    assert_command_works :verify_title, :pattern
    assert_command_works :verify_not_title, :pattern
    assert_command_works :wait_for_title, :pattern
    assert_command_works :wait_for_not_title, :pattern

    assert_command_works :store_body_text, :variable
    assert_command_works :assert_body_text, :pattern
    assert_command_works :assert_not_body_text, :pattern
    assert_command_works :verify_body_text, :pattern
    assert_command_works :verify_not_body_text, :pattern
    assert_command_works :wait_for_body_text, :pattern
    assert_command_works :wait_for_not_body_text, :pattern

    assert_command_works :store_value, :locator, :variable
    assert_command_works :assert_value, :locator, :pattern
    assert_command_works :assert_not_value, :locator, :pattern
    assert_command_works :verify_value, :locator, :pattern
    assert_command_works :verify_not_value, :locator, :pattern
    assert_command_works :wait_for_value, :locator, :pattern
    assert_command_works :wait_for_not_value, :locator, :pattern

    assert_command_works :store_text, :locator, :variable
    assert_command_works :assert_text, :locator, :pattern
    assert_command_works :assert_not_text, :locator, :pattern
    assert_command_works :verify_text, :locator, :pattern
    assert_command_works :verify_not_text, :locator, :pattern
    assert_command_works :wait_for_text, :locator, :pattern
    assert_command_works :wait_for_not_text, :locator, :pattern

    assert_command_works :store_eval, :script, :variable
    assert_command_works :assert_eval, :script, :pattern
    assert_command_works :assert_not_eval, :script, :pattern
    assert_command_works :verify_eval, :script, :pattern
    assert_command_works :verify_not_eval, :script, :pattern
    assert_command_works :wait_for_eval, :script, :pattern
    assert_command_works :wait_for_not_eval, :script, :pattern

    assert_command_works :store_checked, :locator, :variable
    assert_command_works :assert_checked, :locator, :pattern
    assert_command_works :assert_not_checked, :locator, :pattern
    assert_command_works :verify_checked, :locator, :pattern
    assert_command_works :verify_not_checked, :locator, :pattern
    assert_command_works :wait_for_checked, :locator, :pattern
    assert_command_works :wait_for_not_checked, :locator, :pattern

    assert_command_works :store_table, :table_locator, :variable
    assert_command_works :assert_table, :table_locator, :pattern
    assert_command_works :assert_not_table, :table_locator, :pattern
    assert_command_works :verify_table, :table_locator, :pattern
    assert_command_works :verify_not_table, :table_locator, :pattern
    assert_command_works :wait_for_table, :table_locator, :pattern
    assert_command_works :wait_for_not_table, :table_locator, :pattern
    
    assert_raise RuntimeError do
      assert_command_works :store_selected, :locator, :option_locator, :variable
    end
    assert_command_works :assert_selected, :locator, :option_locator
    assert_command_works :assert_not_selected, :locator, :option_locator
    assert_command_works :verify_selected, :locator, :option_locator
    assert_command_works :verify_not_selected, :locator, :option_locator
    assert_command_works :wait_for_selected, :locator, :option_locator
    assert_command_works :wait_for_not_selected, :locator, :option_locator

    assert_command_works :store_selected_options, :locator, :variable
    assert_command_works :assert_selected_options, :locator, :coll_pattern
    assert_command_works :assert_not_selected_options, :locator, :coll_pattern
    assert_command_works :verify_selected_options, :locator, :coll_pattern
    assert_command_works :verify_not_selected_options, :locator, :coll_pattern
    assert_command_works :wait_for_selected_options, :locator, :coll_pattern
    assert_command_works :wait_for_not_selected_options, :locator, :coll_pattern

    assert_command_works :store_select_options, :locator, :variable
    assert_command_works :assert_select_options, :locator, :coll_pattern
    assert_command_works :assert_not_select_options, :locator, :coll_pattern
    assert_command_works :verify_select_options, :locator, :coll_pattern
    assert_command_works :verify_not_select_options, :locator, :coll_pattern
    assert_command_works :wait_for_select_options, :locator, :coll_pattern
    assert_command_works :wait_for_not_select_options, :locator, :coll_pattern

    assert_command_works :store_attribute, :locator_and_attribute_name, :variable
    assert_command_works :assert_attribute, :locator_and_attribute_name, :pattern
    assert_command_works :assert_not_attribute, :locator_and_attribute_name, :pattern
    assert_command_works :verify_attribute, :locator_and_attribute_name, :pattern
    assert_command_works :verify_not_attribute, :locator_and_attribute_name, :pattern
    assert_command_works :wait_for_attribute, :locator_and_attribute_name, :pattern
    assert_command_works :wait_for_not_attribute, :locator_and_attribute_name, :pattern

    assert_command_works :store_text_present, :pattern, :variable
    assert_command_works :assert_text_present, :pattern
    assert_command_works :assert_text_not_present, :pattern
    assert_command_works :verify_text_present, :pattern
    assert_command_works :verify_text_not_present, :pattern
    assert_command_works :wait_for_text_present, :pattern
    assert_command_works :wait_for_text_not_present, :pattern

    assert_command_works :store_element_present, :locator, :variable
    assert_command_works :assert_element_present, :locator
    assert_command_works :assert_element_not_present, :locator
    assert_command_works :verify_element_present, :locator
    assert_command_works :verify_element_not_present, :locator
    assert_command_works :wait_for_element_present, :locator
    assert_command_works :wait_for_element_not_present, :locator

    assert_command_works :store_visible, :locator, :variable
    assert_command_works :assert_visible, :locator
    assert_command_works :assert_not_visible, :locator
    assert_command_works :verify_visible, :locator
    assert_command_works :verify_not_visible, :locator
    assert_command_works :wait_for_visible, :locator
    assert_command_works :wait_for_not_visible, :locator

    assert_command_works :store_editable, :locator, :variable
    assert_command_works :assert_editable, :locator
    assert_command_works :assert_not_editable, :locator
    assert_command_works :verify_editable, :locator
    assert_command_works :verify_not_editable, :locator
    assert_command_works :wait_for_editable, :locator
    assert_command_works :wait_for_not_editable, :locator

    assert_command_works :store_all_buttons, :variable
    assert_command_works :assert_all_buttons, :coll_pattern
    assert_command_works :assert_not_all_buttons, :coll_pattern
    assert_command_works :verify_all_buttons, :coll_pattern
    assert_command_works :verify_not_all_buttons, :coll_pattern
    assert_command_works :wait_for_all_buttons, :coll_pattern
    assert_command_works :wait_for_not_all_buttons, :coll_pattern

    assert_command_works :store_all_links, :variable
    assert_command_works :assert_all_links, :coll_pattern
    assert_command_works :assert_not_all_links, :coll_pattern
    assert_command_works :verify_all_links, :coll_pattern
    assert_command_works :verify_not_all_links, :coll_pattern
    assert_command_works :wait_for_all_links, :coll_pattern
    assert_command_works :wait_for_not_all_links, :coll_pattern

    assert_command_works :store_all_fields, :variable
    assert_command_works :assert_all_fields, :coll_pattern
    assert_command_works :assert_not_all_fields, :coll_pattern
    assert_command_works :verify_all_fields, :coll_pattern
    assert_command_works :verify_not_all_fields, :coll_pattern
    assert_command_works :wait_for_all_fields, :coll_pattern
    assert_command_works :wait_for_not_all_fields, :coll_pattern

    assert_command_works :store_html_source, :variable
    assert_command_works :assert_html_source, :pattern
    assert_command_works :assert_not_html_source, :pattern
    assert_command_works :verify_html_source, :pattern
    assert_command_works :verify_not_html_source, :pattern
    assert_command_works :wait_for_html_source, :pattern
    assert_command_works :wait_for_not_html_source, :pattern

    assert_command_works :store_expression, :script, :variable
    assert_command_works :assert_expression, :script, :pattern
    assert_command_works :assert_not_expression, :script, :pattern
    assert_command_works :verify_expression, :script, :pattern
    assert_command_works :verify_not_expression, :script, :pattern
    assert_command_works :wait_for_expression, :script, :pattern
    assert_command_works :wait_for_not_expression, :script, :pattern
  end

  def test_partial_support
    expected = <<END
<table>
<tr><th colspan="3">Partial support</th></tr>
<tr><td>type</td><td>partial</td><td>RSelenese partial</td></tr>
</table>
END
    input = "include_partial 'override'"
    partial = "type 'partial', 'RSelenese partial'"
    assert_rselenese expected, 'Partial support', input, partial, 'rsel'
  end
  
  def test_partial_support_with_local_assigns
    expected = <<END_EXPECTED
<table>
<tr><th colspan="3">Partial support with local variables</th></tr>
<tr><td>type</td><td>partial</td><td>RSelenese partial</td></tr>
<tr><td>type</td><td>local</td><td>par</td></tr>
<tr><td>type</td><td>local</td><td>tial</td></tr>
</table>
END_EXPECTED
    input = "include_partial 'override', :locator => 'local', :input => ['par', 'tial']"
    partial = <<END_PARTIAL
type 'partial', 'RSelenese partial'
input.each do |i|
  type locator, i
end
END_PARTIAL
    assert_rselenese expected, 'Partial support with local variables', input, partial, 'rsel'
  end

end
