# The accessors available for SeleniumOnRails::TestBuilder tests.
#
# For each +store_foo+ there's +assert_foo+, +assert_not_foo+, +verify_foo+,
# +verify_not_foo+, +wait_for_foo+, +wait_for_not_foo+.
module SeleniumOnRails::TestBuilderAccessors
  
  # Tell Selenium to expect an error on the next command execution.
  #
  # NOTE: <tt>store_error_on_next</tt> is currently not supported by 
  # Selenium Core and is only added to here as a shortcut for 
  # generating the related assertions.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_error_on_next(message)</tt>
  # * <tt>assert_not_error_on_next(message)</tt>
  # * <tt>verify_error_on_next(message)</tt>
  # * <tt>verify_not_error_on_next(message)</tt>
  # * <tt>wait_for_error_on_next(message)</tt>
  # * <tt>wait_for_not_error_on_next(message)</tt>
  def store_error_on_next message
    raise 'Not supported in Selenium Core at the moment'
  end
  
  # Tell Selenium to expect a failure on the next command execution.
  #
  # NOTE: <tt>store_failure_on_next</tt> is currently not supported by 
  # Selenium Core and is only added to here as a shortcut for 
  # generating the related assertions.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_failure_on_next(message)</tt>
  # * <tt>assert_not_failure_on_next(message)</tt>
  # * <tt>verify_failure_on_next(message)</tt>
  # * <tt>verify_not_failure_on_next(message)</tt>
  # * <tt>wait_for_failure_on_next(message)</tt>
  # * <tt>wait_for_not_failure_on_next(message)</tt>
  def store_failure_on_next message
    raise 'Not supported in Selenium Core at the moment'
  end
  
  # Returns the IDs of all windows that the browser knows about.
  #
  # Related Assertions, automatically generated:
  # * <tt>assertAllWindowIds(pattern)</tt>
  # * <tt>assertNotAllWindowIds(pattern)</tt>
  # * <tt>verifyAllWindowIds(pattern)</tt>
  # * <tt>verifyNotAllWindowIds(pattern)</tt>
  # * <tt>waitForAllWindowIds(pattern)</tt>
  # * <tt>waitForNotAllWindowIds(pattern)</tt>
  def store_all_window_ids variable_name
    command 'storeAllWindowIds', variable_name
  end
  
  # Returns the names of all windows that the browser knows about.
  #
  # Related Assertions, automatically generated:
  # * <tt>assertAllWindowNames(pattern)</tt>
  # * <tt>assertNotAllWindowNames(pattern)</tt>
  # * <tt>verifyAllWindowNames(pattern)</tt>
  # * <tt>verifyNotAllWindowNames(pattern)</tt>
  # * <tt>waitForAllWindowNames(pattern)</tt>
  # * <tt>waitForNotAllWindowNames(pattern)</tt>
  def store_all_window_names variable_name
    command 'storeAllWindowNames', variable_name
  end
  
  # Returns the titles of all windows that the browser knows about.
  #
  # Related Assertions, automatically generated:
  # * <tt>assertAllWindowTitles(pattern)</tt>
  # * <tt>assertNotAllWindowTitles(pattern)</tt>
  # * <tt>verifyAllWindowTitles(pattern)</tt>
  # * <tt>verifyNotAllWindowTitles(pattern)</tt>
  # * <tt>waitForAllWindowTitles(pattern)</tt>
  # * <tt>waitForNotAllWindowTitles(pattern)</tt>
  def store_all_window_titles variable_name
    command 'storeAllWindowTitles', variable_name
  end
  
  # Has an alert occurred? 
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_alert_present</tt>
  # * <tt>assert_alert_not_present</tt>
  # * <tt>verify_alert_present</tt>
  # * <tt>verify_alert_not_present</tt>
  # * <tt>wait_for_alert_present</tt>
  # * <tt>wait_for_alert_not_present</tt>
  def store_alert_present variable_name
    command 'storeAlertPresent', variable_name
  end
  
  # Returns every instance of some attribute from all known windows.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_attribute_from_all_windows(attribute_name, pattern)</tt>
  # * <tt>assert_not_attribute_from_all_windows(attribute_name, pattern)</tt>
  # * <tt>verify_attribute_from_all_windows(attribute_name, pattern)</tt>
  # * <tt>verify_not_attribute_from_all_windows(attribute_name, pattern)</tt>
  # * <tt>wait_for_attribute_from_all_windows(attribute_name, pattern)</tt>
  # * <tt>wait_for_not_attribute_from_all_windows(attribute_name, pattern)</tt>
  def store_attribute_from_all_windows attribute_name, variable_name
    command 'storeAttributeFromAllWindows', attribute_name, variable_name
  end

  # Has a prompt occurred? 
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_prompt_present</tt>
  # * <tt>assert_prompt_not_present</tt>
  # * <tt>verify_prompt_present</tt>
  # * <tt>verify_prompt_not_present</tt>
  # * <tt>wait_for_prompt_present</tt>
  # * <tt>wait_for_prompt_not_present</tt>
  def store_prompt_present variable_name
    command 'storePromptPresent', variable_name
  end

  # Has <tt>confirm()</tt> been called? 
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_confirmation_present</tt>
  # * <tt>assert_confirmation_not_present</tt>
  # * <tt>verify_confirmation_present</tt>
  # * <tt>verify_confirmation_not_present</tt>
  # * <tt>wait_for_confirmation_present</tt>
  # * <tt>wait_for_confirmation_not_present</tt>
  def store_confirmation_present variable_name
    command 'storeConfirmationPresent', variable_name
  end
  
  # Return all cookies of the current page under test.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_cookie(pattern)</tt>
  # * <tt>assert_not_cookie(pattern)</tt>
  # * <tt>verify_cookie(pattern)</tt>
  # * <tt>verify_not_cookie(pattern)</tt>
  # * <tt>wait_for_cookie(pattern)</tt>
  # * <tt>wait_for_not_cookie(pattern)</tt>
  def store_cookie variable_name
    command 'storeCookie', variable_name
  end
  
  # Retrieves the text cursor position in the given input element or 
  # textarea; beware, this may not work perfectly on all browsers.
  #
  # This method will fail if the specified element isn't an input element 
  # or textarea, or there is no cursor in the element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_cursor_position(locator, pattern)</tt>
  # * <tt>assert_not_cursor_position(locator, pattern)</tt>
  # * <tt>verify_cursor_position(locator, pattern)</tt>
  # * <tt>verify_not_cursor_position(locator, pattern)</tt>
  # * <tt>wait_for_cursor_position(locator, pattern)</tt>
  # * <tt>wait_for_not_cursor_position(locator, pattern)</tt>
  def store_cursor_position locator, variable_name
    command 'storeCursorPosition', locator, variable_name
  end

  # Retrieves the message of a JavaScript alert generated during the previous
  # action, or fail if there were no alerts.
  #
  # Getting an alert has the same effect as manually clicking OK. If an alert
  # is generated but you do not get/verify it, the next Selenium action will
  # fail.
  #
  # NOTE: under Selenium, JavaScript alerts will NOT pop up a visible alert
  # dialog.
  #
  # NOTE: Selenium does NOT support JavaScript alerts that are generated in a
  # page's <tt>onload()</tt> event handler. In this case a visible dialog WILL be
  # generated and Selenium will hang until someone manually clicks OK.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_alert(pattern)</tt>
  # * <tt>assert_not_alert(pattern)</tt>
  # * <tt>verify_alert_present(pattern)</tt>
  # * <tt>verify_not_alert(pattern)</tt>
  # * <tt>wait_for_alert(pattern)</tt>
  # * <tt>wait_for_not_alert(pattern)</tt>
  def store_alert variable_name
    command 'storeAlert', variable_name
  end

  # Retrieves the message of a JavaScript confirmation dialog generated during
  # the previous action.
  #
  # By default, the confirm function will return +true+, having the same effect
  # as manually clicking OK. This can be changed by prior execution of the
  # +choose_cancel_on_next_confirmation+ command. If a confirmation is
  # generated but you do not get/verify it, the next Selenium action will fail.
  #
  # NOTE: under Selenium, JavaScript confirmations will NOT pop up a visible
  # dialog.
  #
  # NOTE: Selenium does NOT support JavaScript confirmations that are generated
  # in a page's <tt>onload()</tt> event handler. In this case a visible dialog WILL be
  # generated and Selenium will hang until you manually click OK.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_confirmation(pattern)</tt>
  # * <tt>assert_not_confirmation(pattern)</tt>
  # * <tt>verify_confirmation_present(pattern)</tt>
  # * <tt>verify_not_confirmation(pattern)</tt>
  # * <tt>wait_for_confirmation(pattern)</tt>
  # * <tt>wait_for_not_confirmation(pattern)</tt>
  def store_confirmation variable_name
    command 'storeConfirmation', variable_name
  end

  # Retrieves the message of a JavaScript question prompt dialog generated 
  # during the previous action. 
  #
  # Successful handling of the prompt requires prior execution of the 
  # +answer_on_next_prompt+ command. If a prompt is generated but you do not 
  # get/verify it, the next Selenium action will fail.
  #
  # NOTE: under Selenium, JavaScript prompts will NOT pop up a visible dialog.
  #
  # NOTE: Selenium does NOT support JavaScript prompts that are generated in a 
  # page's <tt>onload()</tt> event handler. In this case a visible dialog WILL be
  # generated and Selenium will hang until someone manually clicks OK.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_prompt(pattern)</tt>
  # * <tt>assert_not_prompt(pattern)</tt>
  # * <tt>verify_prompt_present(pattern)</tt>
  # * <tt>verify_not_prompt(pattern)</tt>
  # * <tt>wait_for_prompt(pattern)</tt>
  # * <tt>wait_for_not_prompt(pattern)</tt>
  def store_prompt variable_name
    command 'storePrompt', variable_name
  end

  # Gets the absolute URL of the current page. 
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_absolute_location(pattern)</tt>
  # * <tt>assert_not_absolute_location(pattern)</tt>
  # * <tt>verify_absolute_location_present(pattern)</tt>
  # * <tt>verify_not_absolute_location(pattern)</tt>
  # * <tt>wait_for_absolute_location(pattern)</tt>
  # * <tt>wait_for_not_absolute_location(pattern)</tt>
  def store_absolute_location variable_name
    command 'storeAbsoluteLocation', variable_name
  end

  # Verify the location of the current page ends with the expected location. 
  # If an URL querystring is provided, this is checked as well. 
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_location(pattern)</tt>
  # * <tt>assert_not_location(pattern)</tt>
  # * <tt>verify_location_present(pattern)</tt>
  # * <tt>verify_not_location(pattern)</tt>
  # * <tt>wait_for_location(pattern)</tt>
  # * <tt>wait_for_not_location(pattern)</tt>
  def store_location expected_location, variable_name
    command 'storeLocation', expected_location, variable_name
  end
  
  # Returns the number of pixels between "mousemove" events during 
  # drag_and_drop commands (default=10).
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_mouse_speed(pattern)</tt>
  # * <tt>assert_not_mouse_speed(pattern)</tt>
  # * <tt>verify_mouse_speed(pattern)</tt>
  # * <tt>verify_not_mouse_speed(pattern)</tt>
  # * <tt>wait_for_mouse_speed(pattern)</tt>
  # * <tt>wait_for_not_mouse_speed(pattern)</tt>
  def store_mouse_speed variable_name
    command 'storeMouseSpeed', variable_name
  end
  
  # Gets the title of the current page.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_title(pattern)</tt>
  # * <tt>assert_not_title(pattern)</tt>
  # * <tt>verify_title_present(pattern)</tt>
  # * <tt>verify_not_title(pattern)</tt>
  # * <tt>wait_for_title(pattern)</tt>
  # * <tt>wait_for_not_title(pattern)</tt>
  def store_title variable_name
    command 'storeTitle', variable_name
  end

  # Gets the entire text of the page.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_body_text(pattern)</tt>
  # * <tt>assert_not_body_text(pattern)</tt>
  # * <tt>verify_body_text_present(pattern)</tt>
  # * <tt>verify_not_body_text(pattern)</tt>
  # * <tt>wait_for_body_text(pattern)</tt>
  # * <tt>wait_for_not_body_text(pattern)</tt>
  def store_body_text variable_name
    command 'storeBodyText', variable_name
  end

  # Gets the (whitespace-trimmed) value of an input field (or anything else
  # with a value parameter). For checkbox/radio elements, the value will be
  # "on" or "off" depending on whether the element is checked or not. 
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_value(locator, pattern)</tt>
  # * <tt>assert_not_value(locator, pattern)</tt>
  # * <tt>verify_value_present(locator, pattern)</tt>
  # * <tt>verify_not_value(locator, pattern)</tt>
  # * <tt>wait_for_value(locator, pattern)</tt>
  # * <tt>wait_for_not_value(locator, pattern)</tt>
  def store_value locator, variable_name
    command 'storeValue', locator, variable_name
  end

  # Gets the text of an element. This works for any element that contains text.
  # This command uses either the +textContent+ (Mozilla-like browsers) or the
  # +innerText+ (IE-like browsers) of the element, which is the rendered text
  # shown to the user.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_text(locator, pattern)</tt>
  # * <tt>assert_not_text(locator, pattern)</tt>
  # * <tt>verify_text_present(locator, pattern)</tt>
  # * <tt>verify_not_text(locator, pattern)</tt>
  # * <tt>wait_for_text(locator, pattern)</tt>
  # * <tt>wait_for_not_text(locator, pattern)</tt>
  def store_text locator, variable_name
    command 'storeText', locator, variable_name
  end

  # Gets the result of evaluating the specified JavaScript snippet. The snippet
  # may have multiple lines, but only the result of the last line will be
  # returned.
  #
  # Note that, by default, the snippet will run in the context of the
  # "selenium" object itself, so +this+ will refer to the Selenium object, and
  # +window+ will refer to the top-level runner test window, not the window of
  # your application.
  #
  # If you need a reference to the window of your application, you can refer to
  # <tt>this.browserbot.getCurrentWindow()</tt> and if you need to use a locator to
  # refer to a single element in your application page, you can use
  # <tt>this.page().findElement("foo")</tt> where <tt>"foo"</tt> is your locator.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_eval(script, pattern)</tt>
  # * <tt>assert_not_eval(script, pattern)</tt>
  # * <tt>verify_eval_present(script, pattern)</tt>
  # * <tt>verify_not_eval(script, pattern)</tt>
  # * <tt>wait_for_eval(script, pattern)</tt>
  # * <tt>wait_for_not_eval(script, pattern)</tt>
  def store_eval script, variable_name
    command 'storeEval', script, variable_name
  end

  # Gets whether a toggle-button (checkbox/radio) is checked. Fails if the
  # specified element doesn't exist or isn't a toggle-button.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_checked(locator)</tt>
  # * <tt>assert_not_checked(locator)</tt>
  # * <tt>verify_checked_present(locator)</tt>
  # * <tt>verify_not_checked(locator)</tt>
  # * <tt>wait_for_checked(locator)</tt>
  # * <tt>wait_for_not_checked(locator)</tt>
  def store_checked locator, variable_name
    command 'storeChecked', locator, variable_name
  end

  # Gets the text from a cell of a table.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_table(locator, row, column, pattern)</tt>
  # * <tt>assert_not_table(locator, row, column, pattern)</tt>
  # * <tt>verify_table_present(locator, row, column, pattern)</tt>
  # * <tt>verify_not_table(locator, row, column, pattern)</tt>
  # * <tt>wait_for_table(locator, row, column, pattern)</tt>
  # * <tt>wait_for_not_table(locator, row, column, pattern)</tt>
  def store_table locator, row, column, variable_name
    command 'storeTable', "#{locator}.#{row}.#{column}", variable_name
  end

  # Verifies that the selected option of a drop-down satisfies the
  # <tt>option_locator</tt>.
  #
  # <tt>option_locator</tt> is typically just an option label (e.g. "John Smith").
  #
  # See the <tt>select</tt> command for more information about option locators.
  #
  # NOTE: <tt>store_selected</tt> is currently not supported by Selenium Core.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected(locator, option_locator)</tt>
  # * <tt>assert_not_selected(locator, option_locator)</tt>
  # * <tt>verify_selected_present(locator, option_locator)</tt>
  # * <tt>verify_not_selected(locator, option_locator)</tt>
  # * <tt>wait_for_selected(locator, option_locator)</tt>
  # * <tt>wait_for_not_selected(locator, option_locator)</tt>
  def store_selected locator, option_locator, variable_name
    raise 'Not supported in Selenium Core at the moment'
  end
  
  # Gets option element ID for selected option in the specified select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_id(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_id(select_locator, pattern)</tt>
  # * <tt>verify_selected_id(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_id(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_id(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_id(select_locator, pattern)</tt>
  def store_selected_id select_locator, variable_name
    command 'storeSelectedId', select_locator, variable_name
  end

  # Gets all option element IDs for selected options in the specified select 
  # or multi-select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_ids(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_ids(select_locator, pattern)</tt>
  # * <tt>verify_selected_ids(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_ids(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_ids(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_ids(select_locator, pattern)</tt>
  def store_selected_ids select_locator, variable_name
    command 'storeSelectedIds', select_locator, variable_name
  end
  
  # Gets option index (option number, starting at 0) for selected option in the 
  # specified select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_index(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_index(select_locator, pattern)</tt>
  # * <tt>verify_selected_index(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_index(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_index(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_index(select_locator, pattern)</tt>
  def store_selected_index select_locator, variable_name
    command 'storeSelectedIndex', select_locator, variable_name
  end

  # Gets all option indexes (option number, starting at 0) for selected options 
  # in the specified select or multi-select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_indexes(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_indexes(select_locator, pattern)</tt>
  # * <tt>verify_selected_indexes(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_indexes(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_indexes(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_indexes(select_locator, pattern)</tt>
  def store_selected_indexes select_locator, variable_name
    command 'storeSelectedIndexes', select_locator, variable_name
  end
  
  # Gets option label (visible text) for selected option in the specified select 
  # element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_label(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_label(select_locator, pattern)</tt>
  # * <tt>verify_selected_label(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_label(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_label(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_label(select_locator, pattern)</tt>
  def store_selected_label select_locator, variable_name
    command 'storeSelectedLabel', select_locator, variable_name
  end

  # Gets all option labels (visible text) for selected options in the specified 
  # select or multi-select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_labels(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_labels(select_locator, pattern)</tt>
  # * <tt>verify_selected_labels(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_labels(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_labels(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_labels(select_locator, pattern)</tt>
  def store_selected_labels select_locator, variable_name
    command 'storeSelectedLabels', select_locator, variable_name
  end
  
  # Gets option value (value attribute) for selected option in the specified 
  # select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_value(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_value(select_locator, pattern)</tt>
  # * <tt>verify_selected_value(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_value(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_value(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_value(select_locator, pattern)</tt>
  def store_selected_value select_locator, variable_name
    command 'storeSelectedValue', select_locator, variable_name
  end

  # Gets all option values (value attribute) for selected options in the specified 
  # select or multi-select element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_values(select_locator, pattern)</tt>
  # * <tt>assert_not_selected_values(select_locator, pattern)</tt>
  # * <tt>verify_selected_values(select_locator, pattern)</tt>
  # * <tt>verify_not_selected_values(select_locator, pattern)</tt>
  # * <tt>wait_for_selected_values(select_locator, pattern)</tt>
  # * <tt>wait_for_not_selected_values(select_locator, pattern)</tt>
  def store_selected_values select_locator, variable_name
    command 'storeSelectedValues', select_locator, variable_name
  end
  
  # Determines whether some option in a drop-down menu is selected.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_something_selected(select_locator)</tt>
  # * <tt>assert_not_something_selected(select_locator)</tt>
  # * <tt>verify_something_selected(select_locator)</tt>
  # * <tt>verify_not_something_selected(select_locator)</tt>
  # * <tt>wait_for_something_selected(select_locator)</tt>
  # * <tt>wait_for_not_something_selected(select_locator)</tt>
  def store_something_selected select_locator, variable_name
    command 'storeSomethingSelected', select_locator, variable_name
  end

  # Gets all option labels for selected options in the specified select or
  # multi-select element.
  #
  # The +pattern+ for the automatically generated assertions can either take an
  # array or a pattern.
  #  assert_selected_options 'fruits', ['apple', 'pear']
  #  assert_selected_options 'fruits', 'a*,p*'
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_selected_options(locator, pattern)</tt>
  # * <tt>assert_not_selected_options(locator, pattern)</tt>
  # * <tt>verify_selected_options_present(locator, pattern)</tt>
  # * <tt>verify_not_selected_options(locator, pattern)</tt>
  # * <tt>wait_for_selected_options(locator, pattern)</tt>
  # * <tt>wait_for_not_selected_options(locator, pattern)</tt>
  def store_selected_options locator, variable_name
    command 'storeSelectedOptions', locator, variable_name
  end

  # Gets all option labels in the specified select drop-down.
  #
  # The +pattern+ for the automatically generated assertions can either take an
  # array or a pattern.
  #  assert_select_options 'fruits', ['apple', 'pear']
  #  assert_select_options 'fruits', 'a*,p*'
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_select_options(locator, pattern)</tt>
  # * <tt>assert_not_select_options(locator, pattern)</tt>
  # * <tt>verify_select_options_present(locator, pattern)</tt>
  # * <tt>verify_not_select_options(locator, pattern)</tt>
  # * <tt>wait_for_select_options(locator, pattern)</tt>
  # * <tt>wait_for_not_select_options(locator, pattern)</tt>
  def store_select_options locator, variable_name
    command 'storeSelectOptions', locator, variable_name
  end

  # Gets the value of an element attribute.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_attribute(locator, attribute_name, pattern)</tt>
  # * <tt>assert_not_attribute(locator, attribute_name, pattern)</tt>
  # * <tt>verify_attribute_present(locator, attribute_name, pattern)</tt>
  # * <tt>verify_not_attribute(locator, attribute_name, pattern)</tt>
  # * <tt>wait_for_attribute(locator, attribute_name, pattern)</tt>
  # * <tt>wait_for_not_attribute(locator, attribute_name, pattern)</tt>
  def store_attribute locator, attribute_name, variable_name
    command 'storeAttribute', "#{locator}@#{attribute_name}", variable_name
  end
  
  # Check if these two elements have same parent and are ordered. Two 
  # same elements will not be considered ordered.
  #
  # NOTE: <tt>store_ordered</tt> is currently not supported by Selenium Core.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_ordered(locator_1, locator_2)</tt>
  # * <tt>assert_not_ordered(locator_1, locator_2)</tt>
  # * <tt>verify_ordered(locator_1, locator_2)</tt>
  # * <tt>verify_not_ordered(locator_1, locator_2)</tt>
  # * <tt>wait_for_ordered(locator_1, locator_2)</tt>
  # * <tt>wait_for_not_ordered(locator_1, locator_2)</tt>
  def store_ordered locator_1, locator_2, variable_name
    raise 'Not supported in Selenium Core at the moment'
  end

  # Verifies that the specified text pattern appears somewhere on the rendered
  # page shown to the user.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_text_present(pattern)</tt>
  # * <tt>assert_text_not_present(pattern)</tt>
  # * <tt>verify_text_present(pattern)</tt>
  # * <tt>verify_text_not_present(pattern)</tt>
  # * <tt>wait_for_text_present(pattern)</tt>
  # * <tt>wait_for_text_not_present(pattern)</tt>
  def store_text_present pattern, variable_name
    command 'storeTextPresent', pattern, variable_name
  end

  # Verifies that the specified element is somewhere on the page.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_element_present(locator)</tt>
  # * <tt>assert_element_not_present(locator)</tt>
  # * <tt>verify_element_present(locator)</tt>
  # * <tt>verify_element_not_present(locator)</tt>
  # * <tt>wait_for_element_present(locator)</tt>
  # * <tt>wait_for_element_not_present(locator)</tt>
  def store_element_present locator, variable_name
    command 'storeElementPresent', locator, variable_name
  end

  # Determines if the specified element is visible. An element can be rendered
  # invisible by setting the CSS "visibility" property to "hidden", or the
  # "display" property to "none", either for the element itself or one if its
  # ancestors. This method will fail if the element is not present.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_visible(locator)</tt>
  # * <tt>assert_not_visible(locator)</tt>
  # * <tt>verify_visible(locator)</tt>
  # * <tt>verify_not_visible(locator)</tt>
  # * <tt>wait_for_visible(locator)</tt>
  # * <tt>wait_for_not_visible(locator)</tt>
  def store_visible locator, variable_name
    command 'storeVisible', locator, variable_name
  end
  
  # Retrieves the height of an element. This method will fail if the element 
  # is not present.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_element_height(locator, pattern)</tt>
  # * <tt>assert_not_element_height(locator, pattern)</tt>
  # * <tt>verify_element_height(locator, pattern)</tt>
  # * <tt>verify_not_element_height(locator, pattern)</tt>
  # * <tt>wait_for_element_height(locator, pattern)</tt>
  # * <tt>wait_for_not_element_height(locator, pattern)</tt>
  def store_element_height locator, variable_name
    command 'storeElementHeight', locator, variable_name
  end
  
  # Get the relative index of an element to its parent (starting from 0). 
  # The comment node and empty text node will be ignored.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_element_index(locator, pattern)</tt>
  # * <tt>assert_not_element_index(locator, pattern)</tt>
  # * <tt>verify_element_index(locator, pattern)</tt>
  # * <tt>verify_not_element_index(locator, pattern)</tt>
  # * <tt>wait_for_element_index(locator, pattern)</tt>
  # * <tt>wait_for_not_element_index(locator, pattern)</tt>
  def store_element_index locator, variable_name
    command 'storeElementIndex', locator, variable_name
  end
  
  # Retrieves the width of an element. This method will fail if the element 
  # is not present.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_element_width(locator, pattern)</tt>
  # * <tt>assert_not_element_width(locator, pattern)</tt>
  # * <tt>verify_element_width(locator, pattern)</tt>
  # * <tt>verify_not_element_width(locator, pattern)</tt>
  # * <tt>wait_for_element_width(locator, pattern)</tt>
  # * <tt>wait_for_not_element_width(locator, pattern)</tt>
  def store_element_width locator, variable_name
    command 'storeElementWidth', locator, variable_name
  end
  
  # Retrieves the horizontal position of an element. This method will fail 
  # if the element is not present.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_element_position_left(locator, pattern)</tt>
  # * <tt>assert_not_element_position_left(locator, pattern)</tt>
  # * <tt>verify_element_position_left(locator, pattern)</tt>
  # * <tt>verify_not_element_position_left(locator, pattern)</tt>
  # * <tt>wait_for_element_position_left(locator, pattern)</tt>
  # * <tt>wait_for_not_element_position_left(locator, pattern)</tt>
  def store_element_position_left locator, variable_name
    command 'storeElementPositionLeft', locator, variable_name
  end
  
  # Retrieves the vertical position of an element. This method will fail 
  # if the element is not present.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_element_position_top(locator, pattern)</tt>
  # * <tt>assert_not_element_position_top(locator, pattern)</tt>
  # * <tt>verify_element_position_top(locator, pattern)</tt>
  # * <tt>verify_not_element_position_top(locator, pattern)</tt>
  # * <tt>wait_for_element_position_top(locator, pattern)</tt>
  # * <tt>wait_for_not_element_position_top(locator, pattern)</tt>
  def store_element_position_top locator, variable_name
    command 'storeElementPositionTop', locator, variable_name
  end
  
  # Return the contents of the log.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_log_messages(pattern)</tt>
  # * <tt>assert_not_log_messages(pattern)</tt>
  # * <tt>verify_log_messages(pattern)</tt>
  # * <tt>verify_not_log_messages(pattern)</tt>
  # * <tt>wait_for_log_messages(pattern)</tt>
  # * <tt>wait_for_not_log_messages(pattern)</tt>
  def store_log_messages variable_name
    command 'storeLogMessages', variable_name
  end

  # Determines whether the specified input element is editable, i.e. hasn't
  # been disabled. This method will fail if the specified element isn't an
  # input element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_editable(locator)</tt>
  # * <tt>assert_not_editable(locator)</tt>
  # * <tt>verify_editable(locator)</tt>
  # * <tt>verify_not_editable(locator)</tt>
  # * <tt>wait_for_editable(locator)</tt>
  # * <tt>wait_for_not_editable(locator)</tt>
  def store_editable locator, variable_name
    command 'storeEditable', locator, variable_name
  end

  # Returns the IDs of all buttons on the page.
  #
  # If a given button has no ID, it will appear as "" in this array.
  #
  # The +pattern+ for the automatically generated assertions can either take an
  # array or a pattern.
  #  assert_all_buttons ['but1', 'but2']
  #  assert_all_buttons 'but?,but?*'
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_all_buttons(pattern)</tt>
  # * <tt>assert_not_all_buttons(pattern)</tt>
  # * <tt>verify_all_buttons(pattern)</tt>
  # * <tt>verify_not_all_buttons(pattern)</tt>
  # * <tt>wait_for_all_buttons(pattern)</tt>
  # * <tt>wait_for_not_all_buttons(pattern)</tt>
  def store_all_buttons variable_name
    command 'storeAllButtons', variable_name
  end

  # Returns the IDs of all links on the page.
  #
  # If a given link has no ID, it will appear as "" in this array.
  #
  # The +pattern+ for the automatically generated assertions can either take an
  # array or a pattern.
  #  assert_all_links ['link1', 'link2']
  #  assert_all_links 'link?,link?*'
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_all_links(pattern)</tt>
  # * <tt>assert_not_all_links(pattern)</tt>
  # * <tt>verify_all_links(pattern)</tt>
  # * <tt>verify_not_all_links(pattern)</tt>
  # * <tt>wait_for_all_links(pattern)</tt>
  # * <tt>wait_for_not_all_links(pattern)</tt>
  def store_all_links variable_name
    command 'storeAllLinks', variable_name
  end

  # Returns the IDs of all input fields on the page.
  #
  # If a given field has no ID, it will appear as "" in this array.
  #
  # The +pattern+ for the automatically generated assertions can either take an
  # array or a pattern.
  #  assert_all_fields ['field1', 'field2']
  #  assert_all_fields 'field?,field?*'
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_all_fields(pattern)</tt>
  # * <tt>assert_not_all_fields(pattern)</tt>
  # * <tt>verify_all_fields(pattern)</tt>
  # * <tt>verify_not_all_fields(pattern)</tt>
  # * <tt>wait_for_all_fields(pattern)</tt>
  # * <tt>wait_for_not_all_fields(pattern)</tt>
  def store_all_fields variable_name
    command 'storeAllFields', variable_name
  end

  # Returns the entire HTML source between the opening and closing "html" tags.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_html_source(pattern)</tt>
  # * <tt>assert_not_html_source(pattern)</tt>
  # * <tt>verify_html_source(pattern)</tt>
  # * <tt>verify_not_html_source(pattern)</tt>
  # * <tt>wait_for_html_source(pattern)</tt>
  # * <tt>wait_for_not_html_source(pattern)</tt>
  def store_html_source variable_name
    command 'storeHtmlSource', variable_name
  end

  # Returns the specified expression.
  #
  # This is useful because of JavaScript preprocessing.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_expression(expression, pattern)</tt>
  # * <tt>assert_not_expression(expression, pattern)</tt>
  # * <tt>verify_expression(expression, pattern)</tt>
  # * <tt>verify_not_expression(expression, pattern)</tt>
  # * <tt>wait_for_expression(expression, pattern)</tt>
  # * <tt>wait_for_not_expression(expression, pattern)</tt>
  def store_expression expression, variable_name
    command 'storeExpression', expression, variable_name
  end
  
  # Determine whether current/locator identify the frame containing this 
  # running code.
  #
  # This is useful in proxy injection mode, where this code runs in every 
  # browser frame and window, and sometimes the selenium server needs to 
  # identify the "current" frame. In this case, when the test calls select_frame, 
  # this routine is called for each frame to figure out which one has been 
  # selected. The selected frame will return true, while all others will return 
  # false.
  #
  # NOTE: <tt>store_whether_this_frame_match_frame_expression</tt> is currently 
  # not supported by Selenium Core.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_whether_this_frame_match_frame_expression(current_frame_string, target)</tt>
  # * <tt>assert_not_whether_this_frame_match_frame_expression(current_frame_string, target)</tt>
  # * <tt>verify_whether_this_frame_match_frame_expression(current_frame_string, target)</tt>
  # * <tt>verify_not_whether_this_frame_match_frame_expression(current_frame_string, target)</tt>
  # * <tt>wait_for_whether_this_frame_match_frame_expression(current_frame_string, target)</tt>
  # * <tt>wait_for_not_whether_this_frame_match_frame_expression(current_frame_string, target)</tt>
  def store_whether_this_frame_match_frame_expression current_frame_string, target, variable_name
    raise 'Not supported in Selenium Core at the moment'
  end
  
  # Determine whether current_window_string plus target identify the window 
  # containing this running code.
  #
  # This is useful in proxy injection mode, where this code runs in every browser 
  # frame and window, and sometimes the selenium server needs to identify the 
  # "current" window. In this case, when the test calls select_window, this routine 
  # is called for each window to figure out which one has been selected. The selected 
  # window will return true, while all others will return false.
  #
  # NOTE: <tt>store_whether_this_window_match_window_expression</tt> is currently 
  # not supported by Selenium Core.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_whether_this_window_match_window_expression(current_window_string, target)</tt>
  # * <tt>assert_not_whether_this_window_match_window_expression(current_window_string, target)</tt>
  # * <tt>verify_whether_this_window_match_window_expression(current_window_string, target)</tt>
  # * <tt>verify_not_whether_this_window_match_window_expression(current_window_string, target)</tt>
  # * <tt>wait_for_whether_this_window_match_window_expression(current_window_string, target)</tt>
  # * <tt>wait_for_not_whether_this_window_match_window_expression(current_window_string, target)</tt>
  def store_whether_this_window_match_window_expression current_window_string, target, variable_name
    raise 'Not supported in Selenium Core at the moment'
  end

private
  # Generates all assertions for the accessors.
  def self.generate_methods
    public_instance_methods.each do |method|
      case method
      when 'store_alert_present',
           'store_prompt_present',
           'store_confirmation_present'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do
             command command_name
          end
        end
      when 'store_error_on_next',
           'store_failure_on_next',
           'store_alert',
           'store_all_window_ids',
           'store_all_window_names',
           'store_all_window_titles',
           'store_confirmation',
           'store_cookie',
           'store_log_messages',
           'store_mouse_speed',
           'store_prompt',
           'store_title',
           'store_body_text',
           'store_text_present',
           'store_element_present',
           'store_visible',
           'store_editable',
           'store_html_source',
           'store_checked',
           'store_something_selected'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |pattern|
             command command_name, pattern
          end
        end
      when 'store_attribute_from_all_windows',
           'store_value',
           'store_text',
           'store_eval',
           'store_cursor_position',
           'store_selected',
           'store_selected_id',
           'store_selected_ids',
           'store_selected_index',
           'store_selected_indexes',
           'store_selected_label',
           'store_selected_labels',
           'store_selected_value',
           'store_selected_values',
           'store_element_height',
           'store_element_index',
           'store_element_width',
           'store_element_position_left',
           'store_element_position_top',
           'store_expression',
           'store_ordered',
           'store_whether_this_frame_match_frame_expression',
           'store_whether_this_window_match_window_expression'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |arg1, arg2|
             command command_name, arg1, arg2
          end
        end
      when 'store_all_buttons',
           'store_all_links',
           'store_all_fields'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |pattern|
             command command_name, collection_arg(pattern)
          end
        end
      when 'store_select_options',
           'store_selected_options'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |locator, pattern|
             command command_name, locator, collection_arg(pattern)
          end
        end
      when 'store_attribute'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |locator, attribute_name, pattern|
             command command_name, "#{locator}@#{attribute_name}", pattern
          end
        end
      when 'store_table'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |locator, row, column, pattern|
             command command_name, "#{locator}.#{row}.#{column}", pattern
          end
        end
      when 'store_absolute_location',
           'store_location'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |pattern|
            if method == 'store_absolute_location' and pattern.is_a? Hash
              pattern[:only_path] = false
            end

            command command_name, url_arg(pattern)
          end
        end
      when /^store_/
         raise 'internal error'
      end
    end
  end

  # Generates all the assertions needed given a +store_method+.
  def self.each_assertion store_method
    before_negation = nil
    after_negation = store_method.split('_')[1..-1] #throw away 'store'
    if after_negation.last == 'present'
      before_negation, after_negation = after_negation, after_negation.pop
    end

    ['assert', 'verify', ['wait','for']].each do |action|
      [nil, 'not'].each do |negation|
        name = [action, before_negation, negation, after_negation].flatten.reject{|a|a.nil?}
        method_name = name.join '_'
        command = name.inject(name.shift.clone) {|n, p| n << p.capitalize}
        yield method_name, command
      end
    end
  end

  generate_methods
end
