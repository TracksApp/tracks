# The actions available for SeleniumOnRails::TestBuilder tests.
#
# For each action +foo+ there's also an action +foo_and_wait+.
module SeleniumOnRails::TestBuilderActions
  # Tell Selenium on Rails to clear the session and load any fixtures.  DO
  # NOT CALL THIS AGAINST NON-TEST DATABASES.
  # The supported +options+ are <code>:keep_session</code>, 
  # <code>:fixtures</code> and <code>:clear_tables</code>
  #   setup
  #   setup :keep_session
  #   setup :fixtures => :all
  #   setup :keep_session, :fixtures => [:foo, :bar]
  #   setup :clear_tables => [:foo, :bar]
  def setup options = {}
    options = {options => nil} unless options.is_a? Hash

    opts = {:controller => 'selenium', :action => 'setup'}
    opts[:keep_session] = true if options.has_key? :keep_session

    [:fixtures, :clear_tables].each do |key|
      if (f = options[key])
        f = [f] unless f.is_a? Array
        opts[key] = f.join ','
      end
    end

    open opts
  end

  # Includes a partial.
  # The path is relative to the Selenium tests root. The starting _ and the file
  # extension don't have to be specified.
  #   #include test/selenium/_partial.*
  #   include_partial 'partial'
  #   #include test/selenium/suite/_partial.*
  #   include_partial 'suite/partial'
  #   #include test/selenium/suite/_partial.* and provide local assigns
  #   include_partial 'suite/partial', :foo => bar
  def include_partial path, local_assigns = {}
    partial = @view.render :partial => path, :locals => local_assigns
    @output << partial
  end

  # Clicks on a link, button, checkbox or radio button. If the click action
  # causes a new page to load (like a link usually does), call 
  # +wait_for_page_to_load+.
  def click locator
    command 'click', locator
  end
  
  # Clicks on a link, button, checkbox or radio button. If the click action causes 
  # a new page to load (like a link usually does), call wait_for_page_to_load.
  def click_at locator, coord_string
    command 'clickAt', locator, coord_string
  end

  # Explicitly simulate an event (e.g. <tt>"focus"</tt>, <tt>"blur"</tt>), to
  # trigger the corresponding <tt>"on_event_"</tt> handler.
  def fire_event locator, event_name
    command 'fireEvent', locator, event_name
  end

  # Simulates a user pressing and releasing a key.
  #
  # +keycode+ is the numeric keycode of the key to be pressed, normally the
  # ASCII value of that key.
  def key_press locator, keycode
    command 'keyPress', locator, keycode
  end
  
  # Simulates a user pressing a key (without releasing it yet).
  #
  # +keycode+ is the numeric keycode of the key to be pressed, normally the
  # ASCII value of that key.
  def key_down locator, keycode
    command 'keyDown', locator, keycode
  end
  
  # Simulates a user releasing a key.
  #
  # +keycode+ is the numeric keycode of the key to be released, normally the
  # ASCII value of that key.
  def key_up locator, keycode
    command 'keyUp', locator, keycode
  end

  # Simulates a user hovering a mouse over the specified element.
  def mouse_over locator
    command 'mouseOver', locator
  end
  
  # Simulates a user pressing the mouse button (without releasing it yet) on the
  # specified element.
  def mouse_down locator
    command 'mouseDown', locator
  end

  # Sets the value of an input field, as though you typed it in. 
  #
  # Can also be used to set the value of combo boxes, check boxes, etc. In these
  # cases, +value+ should be the value of the option selected, not the visible
  # text.
  def type locator, value
    command 'type', locator, value
  end

  # Check a toggle-button (checkbox/radio).
  def check locator
    command 'check', locator
  end

  # Uncheck a toggle-button (checkbox/radio).
  def uncheck locator
    command 'uncheck', locator
  end

  # Select an option from a drop-down using an option locator.
  #
  # Option locators provide different ways of specifying options of an HTML
  # Select element (e.g. for selecting a specific option, or for asserting that
  # the selected option satisfies a specification). There are several forms of
  # Select Option Locator.
  #
  # * label=labelPattern 
  #   matches options based on their labels, i.e. the visible text. (This is the
  #   default.)
  #     label=regexp:^[Oo]ther
  # * value=valuePattern
  #   matches options based on their values.
  #     value=other
  # * id=id
  #   matches options based on their ids.
  #     id=option1
  # * index=index
  #   matches an option based on its index (offset from zero). 
  #     index=2 
  #
  # If no option locator prefix is provided, the default behaviour is to match
  # on label. 
  def select locator, option_locator
    command 'select', locator, option_locator
  end

  # Add a selection to the set of selected options in a multi-select element
  # using an option locator.
  #
  # See the <tt>#select</tt> command for more information about option locators.
  def add_selection locator, option_locator
    command 'addSelection', locator, option_locator
  end

  # Remove a selection from the set of selected options in a multi-select
  # element using an option locator.
  #
  # See the +select+ command for more information about option locators.
  def remove_selection locator, option_locator
    command 'removeSelection', locator, option_locator
  end

  # Submit the specified form. This is particularly useful for forms without
  # submit buttons, e.g. single-input "Search" forms.
  def submit locator
    command 'submit', locator
  end

  # Opens an URL in the test frame. This accepts both relative and absolute
  # URLs. The <tt>open</tt> command waits for the page to load before
  # proceeding, i.e. you don't have to call +wait_for_page_to_load+.
  #
  # Note: The URL must be on the same domain as the runner HTML due to security
  # restrictions in the browser (Same Origin Policy).
  def open url
    command 'open', url_arg(url)
  end

  # Selects a popup window; once a popup window has been selected, all commands
  # go to that window. To select the main window again, use +nil+ as the target.
  def select_window window_id
    command 'selectWindow', window_id||'null'
  end

  # Waits for a popup window to appear and load up.
  #
  # The +timeout+ is specified in milliseconds.
  def wait_for_popup window_id, timeout
    command 'waitForPopUp', window_id||'null', timeout
  end

  # By default, Selenium's overridden <tt>window.confirm()</tt> function will return
  # +true+, as if the user had manually clicked OK. After running this command,
  # the next call to <tt>confirm()</tt> will return +false+, as if the user had clicked
  # Cancel. 
  def choose_cancel_on_next_confirmation
    command 'chooseCancelOnNextConfirmation'
  end

  # Instructs Selenium to return the specified answer string in response to the
  # next JavaScript prompt (<tt>window.prompt()</tt>). 
  def answer_on_next_prompt answer
    command 'answerOnNextPrompt', answer
  end

  # Simulates the user clicking the "back" button on their browser. 
  def go_back
    command 'goBack'
  end

  # Simulates the user clicking the "Refresh" button on their browser. 
  def refresh
    command 'refresh'
  end

  # Simulates the user clicking the "close" button in the titlebar of a popup
  # window or tab.
  def close
    command 'close'
  end
  
  # Simulates the user pressing the alt key and hold it down until do_alt_up()
  # is called or a new page is loaded.
  def alt_key_down
    command 'altKeyDown'
  end
  
  # Simulates the user releasing the alt key.
  def alt_key_up
    command 'altKeyUp'
  end
  
  # Halt the currently running test, and wait for the user to press the Continue 
  # button. This command is useful for debugging, but be careful when using it, 
  # because it will force automated tests to hang until a user intervenes manually.
  #
  # NOTE: <tt>break</tt> is a reserved word in Ruby, so we have to simulate
  # Selenium core's <tt>break()</tt> with <tt>brake()</tt>
  def brake
    command 'break'
  end
  
  # Simulates the user pressing the alt key and hold it down until do_control_up()
  # is called or a new page is loaded.
  def control_key_down
    command 'controlKeyDown'
  end
  
  # Simulates the user releasing the control key.
  def control_key_up
    command 'controlKeyUp'
  end
  
  # Create a new cookie whose path and domain are same with those of current page 
  # under test, unless you specified a path for this cookie explicitly.
  #
  # Arguments:
  # * <tt>name_value_pair</tt> - name and value of the cookie in a format "name=value"
  # * <tt>options_string</tt> - options for the cookie. Currently supported options 
  #   include 'path' and 'max_age'. The options_string's format is 
  #   <tt>"path=/path/, max_age=60"</tt>. The order of options are irrelevant, the 
  #   unit of the value of 'max_age' is second.
  def create_cookie name_value_pair, options_string
    command 'createCookie', name_value_pair, options_string
  end
  
  # Delete a named cookie with specified path.
  def delete_cookie name, path
    command 'deleteCookie', name, path
  end
  
  # Double clicks on a link, button, checkbox or radio button. If the double click action 
  # causes a new page to load (like a link usually does), call <tt>wait_for_page_to_load</tt>.
  def double_click locator
    command 'doubleClick', locator
  end
  
  # Doubleclicks on a link, button, checkbox or radio button. If the action causes a new page 
  # to load (like a link usually does), call <tt>wait_for_page_to_load</tt>.
  def double_click_at locator, coord_string
    command 'doubleClickAt', locator, coord_string
  end
  
  # Drags an element a certain distance and then drops it.
  def drag_and_drop locator, movements_string
    command 'dragAndDrop', locator, movements_string
  end
  
  # Drags an element and drops it on another element.
  def drag_and_drop_to_object locator_of_object_to_be_dragged, locator_of_drag_destination_object
    command 'dragAndDropToObject', locator_of_object_to_be_dragged, locator_of_drag_destination_object
  end
  
  # Prints the specified message into the third table cell in your Selenese
  # tables. 
  # Useful for debugging.
  def echo message
    command 'echo', message
  end
    
  # Briefly changes the backgroundColor of the specified element yellow.
  # Useful for debugging.
  def highlight locator
    command 'highlight', locator
  end
  
  # Press the meta key and hold it down until <tt>doMetaUp()</tt> is called or
  # a new page is loaded.
  def meta_key_down
    command 'metaKeyDown'
  end
  
  # Release the meta key.
  def meta_key_up
    command 'metaKeyUp'
  end
  
  # Simulates a user pressing the mouse button (without releasing it yet) on the specified
  # element.
  def mouse_down_at locator, coord_string
    command 'mouseDownAt', locator, coord_string
  end
  
  # Simulates a user moving the mouse.
  def mouse_move locator
    command 'mouseMove', locator
  end
  
  # Simulates a user moving the mouse relative to the specified element.
  def mouse_move_at locator, coord_string
    command 'mouseMoveAt', locator, coord_string
  end
  
  # Simulates the user moving the mouse off the specified element.
  def mouse_out locator
    command 'mouseOut', locator
  end
  
  # Simulates the user releasing the mouse button on the specified element.
  def mouse_up locator
    command 'mouseUp', locator
  end
  
  # Simulates a user pressing the mouse button (without releasing it yet) on the
  # specified element.
  def mouse_up_at locator, coord_string
    command 'mouseUpAt', locator, coord_string
  end
  
  # Opens a popup window (if a window with that ID isn't already open). After opening the
  # window, you'll need to select it using the <tt>select_window</tt> command.
  #
  # This command can also be a useful workaround for bug SEL-339. In some cases, Selenium
  # will be unable to intercept a call to window.open (if the call occurs during or before
  # the "onLoad" event, for example). In those cases, you can force Selenium to notice the
  # open window's name by using the Selenium openWindow command, using an empty (blank) url,
  # like this: <tt>open_window("", "myFunnyWindow")</tt>.
  def open_window url, window_id
    command 'openWindow', url, window_id
  end
  
  # Wait for the specified amount of time (in milliseconds).
  def pause wait_time
    command 'pause', wait_time
  end
  
  # Unselects all of the selected options in a multi-select element.
  def remove_all_selections locator
    command 'removeAllSelections', locator
  end
  
  # Selects a frame within the current window. (You may invoke this command multiple times
  # to select nested frames.) To select the parent frame, use "relative=parent" as a
  # locator; to select the top frame, use "relative=top".
  #
  # You may also use a DOM expression to identify the frame you want directly, like this:
  # <tt>dom=frames["main"].frames["subframe"]</tt>
  def select_frame locator
    command 'selectFrame', locator
  end
  
  # Moves the text cursor to the specified position in the given input element or textarea.
  # This method will fail if the specified element isn't an input element or textarea.
  def set_cursor_position locator, position
    command 'setCursorPosition', locator, position
  end
  
  # Configure the number of pixels between "mousemove" events during dragAndDrop commands
  # (default=10).
  # Setting this value to 0 means that we'll send a "mousemove" event to every single pixel
  # in between the start location and the end location; that can be very slow, and may
  # cause some browsers to force the JavaScript to timeout.
  #
  # If the mouse speed is greater than the distance between the two dragged objects, we'll 
  # just send one "mousemove" at the start location and then one final one at the end location.
  def set_mouse_speed pixels
    command 'setMouseSpeed', pixels
  end
  
  # Press the shift key and hold it down until <tt>doShiftUp()</tt> is called or a new page
  # is loaded.
  def shift_key_down
    command 'shiftKeyDown'
  end
  
  # Release the shift key.
  def shift_key_up
    command 'shiftKeyUp'
  end
  
  # This command is a synonym for <tt>store_expression</tt>.
  def store expression, variable_name
    command 'store', expression, variable_name
  end
  
  # Simulates keystroke events on the specified element, as though you typed the value 
  # key-by-key.
  #
  # This is a convenience method for calling <tt>key_down</tt>, <tt>key_up</tt>, 
  # <tt>key_press</tt> for every character in the specified string; this is useful for
  # dynamic UI widgets (like auto-completing combo boxes) that require explicit key events.
  #
  # Unlike the simple "type" command, which forces the specified value into the page directly,
  # this command may or may not have any visible effect, even in cases where typing keys would
  # normally have a visible effect. For example, if you use "<tt>type_keys</tt>" on a form
  # element, you may or may not see the results of what you typed in the field.
  #
  # In some cases, you may need to use the simple "type" command to set the value of the field
  # and then the "<tt>type_keys</tt>" command to send the keystroke events corresponding to
  # what you just typed.
  def type_keys locator, value
    command 'typeKeys', locator, value
  end
  
  # Gives focus to a window.
  def window_focus window_name
    command 'windowFocus', window_name
  end
  
  # Resize window to take up the entire screen.
  def window_maximize window_name
    command 'windowMaximize', window_name
  end
  
  # Writes a message to the status bar and adds a note to the browser-side log. 
  #
  # +context+ is the message sent to the browser.
  #
  # +log_level_threshold+ can be +nil+, <tt>:debug</tt>, <tt>:info</tt>, 
  # <tt>:warn</tt> or <tt>:error</tt>.
  def set_context context, log_level_threshold = nil
    if log_level_threshold
      command 'setContext', context, log_level_threshold.to_s
    else
      command 'setContext', context
    end
  end

  # Runs the specified JavaScript snippet repeatedly until it evaluates to
  # +true+. The snippet may have multiple lines, but only the result of the last
  # line will be considered. 
  # 
  # Note that, by default, the snippet will be run in the runner's test window,
  # not in the window of your application. To get the window of your
  # application, you can use the JavaScript snippet
  # <tt>selenium.browserbot.getCurrentWindow()</tt>, and then run your 
  # JavaScript in there.
  #
  # +timeout+ is specified in milliseconds.
  def wait_for_condition script, timeout
    command 'waitForCondition', script, timeout
  end

  # Specifies the amount of time that Selenium will wait for actions to
  # complete. 
  #
  # Actions that require waiting include +open+ and the <tt>wait_for*</tt>
  # actions.
  #
  # The default timeout is 30 seconds. 
  #
  # +timeout+ is specified in milliseconds.
  def set_timeout timeout
    command 'setTimeout', timeout
  end

  # Waits for a new page to load. 
  #
  # You can use this command instead of the +and_wait+ suffixes,
  # +click_and_wait+, +select_and_wait+, +type_and_wait+ etc. (which are only
  # available in the JS API).
  #
  # Selenium constantly keeps track of new pages loading, and sets a
  # +newPageLoaded+ flag when it first notices a page load. Running any other
  # Selenium command after turns the flag to +false+. Hence, if you want to wait
  # for a page to load, you must wait immediately after a Selenium command that
  # caused a page-load.
  #
  # +timeout+ is specified in milliseconds.
  def wait_for_page_to_load timeout
    command 'waitForPageToLoad', timeout
  end

private
  # Generates the corresponding +_and_wait+ for each action.
  def self.generate_and_wait_actions
    public_instance_methods.each do |method|
      define_method method + '_and_wait' do |*args|
        methods_array = method.split("_")
        send 'command_and_wait', methods_array.first.downcase + methods_array[1..-1].collect{|part| part.camelize}.join, *args
      end
    end
  end

  generate_and_wait_actions
end

