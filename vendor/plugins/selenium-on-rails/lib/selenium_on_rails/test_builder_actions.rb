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
        make_command_waiting do
          send method, *args
        end
      end
    end
  end

  generate_and_wait_actions
end

