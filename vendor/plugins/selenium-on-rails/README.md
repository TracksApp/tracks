Welcome to the Selenium on Rails README.  Exciting isn't it?

# Selenium on Rails #

## Overview ##

Selenium on Rails provides an easy way to test Rails application with 
SeleniumCore[http://www.openqa.org/selenium-core/].

This plugin does four things:

1. The Selenium Core files don't have to pollute <tt>/public</tt>.
2. No need to create suite files, they are generated on the fly -- one suite per directory in <tt>/test/selenium</tt> (suites can be nested).
3. Instead of writing the test cases in HTML you can use a number of better formats (see <tt>Formats</tt>).
4. Loading of fixtures and wiping of session (<tt>/selenium/setup</tt>).

## Installation ##

Rails periodically changes the way that it renders pages, which unfortunately breaks backwards versions of Selenium on Rails.  Therefore there are different
installation locations depending on your version of Rails:

*Rails 2.2 and up:*

	http://svn.openqa.org/svn/selenium-on-rails/stable/selenium-on-rails


*Rails 2.1:*

	http://svn.openqa.org/svn/selenium-on-rails/tags/rails_2_1/selenium-on-rails


*Before Rails 2.1:*

	http://svn.openqa.org/svn/selenium-on-rails/tags/pre-rails-2-1/selenium-on-rails


The latest release is always kept on GitHub at 

	git clone git://github.com/paytonrules/selenium-on-rails.git


To install:

1. Install Selenium on Rails: script/plugin install <URL>
2. If you‘re on Windows, gem install win32-open3
3. If the RedCloth gem is available the Selenese test cases can use it for better markup.
4. Run the Rakefile in the plugin‘s directory to run the tests in order to see that everything works. (If RedCloth isn‘t installed a few tests will fail since they assume RedCloth is installed.)
5. Create a test case: script/generate selenium <TestName>
6. Start the server: script/server -e test
7. Point your browser to localhost:3000/selenium
8. If everything works as expected you should see the Selenium test runner. The north east frame contains all your test cases (just one for now), and the north frame contains your test case.

## Formats ##

The test cases can be written in a number of formats. Which one you choose is a matter of taste. You can generate your test files by running script/generate selenium or by creating them manually in your /test/selenium directory.

## RSelenese, .rsel ##

RSelenese lets you write your tests in Ruby. This is my favorite format.

	setup :fixtures => :all
	open '/'
	assert_title 'Home'
	('a'..'z').each {|c| open :controller => 'user', :action => 'create', :name => c }

See SeleniumOnRails::TestBuilder for available commands. *IMPORTANT NOTE:* RSelenese generates the HTML tables for Selenium behind the scenes when the page is loaded - ONCE. That means code like this:

	(1..10).each do |index|
		do something
	end

Will only be executed when the test is loaded, not when the test is run. This is a common error and leads to tests that work the first time and fail the second time.

## Selenese, .sel ##

Selenese is the dumbest format (in a good way). You just write your commands delimited by | characters.

	|open|/selenium/setup|
	|open|/|
	|goBack|

If you don‘t want to write Selenese tests by hand you can use SeleniumIDE which has support for Selenese.

## HTML/RHTML ##

You can write your tests in HTML/RHTML but that‘s mostly useful if you have existing tests you want to reuse.

## Partial test cases ##

If you have some common actions you want to do in several test cases you can put them in a separate partial test case and include them in your other test cases. This is highly recommended, just as small functions would be recommended in structured programming.

A partial test case is just like a normal test case besides that its filename has to start with _:

	#_login.rsel
	open '/login'
	type 'name', name
	type 'password', password
	click 'submit', :wait=>true

To include a partial test case in a RSelenese test case:

	include_partial 'login', :name => 'Jane Doe', :password => 'Jane Doe'.reverse

in a Selenese test case:

	|includePartial|login|name=John Doe|password=eoD nhoJ|

and in a RHTML test case:

	<%= render :partial => 'login', :locals => {:name = 'Joe Schmo', :password => 'Joe Schmo'.reverse} %>

## Configuration ##

There are a number of settings available. You make them by renaming selenium.yml.example to selenium.yml and placing it in your rails app's config 
file.  Make your changes in that file.

## Environments ##

Per default this plugin is only available in test environment. You can change this by setting environments, such as:

	#selenium.yml
	environments:
		- test
		- development

## Selenium Core path ##

If you don‘t want to use the bundled Selenium Core version you can set selenium_path to the directory where Selenium Core is stored.

	#config.yml
	selenium_path: 'c:\selenium'

## Rake Task ##

You can run all your Selenium tests as a Rake task. If you're using a continuous builder this is a great way to integrate selenium into your build process.  First, if you‘re on Windows, you have to make sure win32-open3 is installed. Then you have to configure which browsers you want to run, like this:


	#config.yml
	browsers:
		firefox: 'c:\Program Files\Mozilla Firefox\firefox.exe'
		ie: 'c:\Program Files\Internet Explorer\iexplore.exe'

Now you‘re all set. First start a server:

	script/server -e test

Then run the tests:
	
	rake test:acceptance
	
Now it should work, otherwise let me know!

## Store results ##

If you want to store the results from a test:acceptance you just need to set in which directory they should be stored:

	#config.yml
	result_dir: 'c:\result'
	
So when you run rake test:acceptance the tables with the results will be stored as .html files in that directory.

## user_extension.js ##

Selenium has support for user_extension.js which is a way to extend the functionality of Selenium Core. Selenium on Rails now provides the means for you to extend it's functionality to match.

To get you started, we've included the example files lib/test\_builder\_user\_accessors.rb.example and lib/test\_builder\_user\_actions.rb.example that replicate the sample extensions in Selenium Core's user-extensions.js.sample.

To get these examples running, simply remove the .example and .sample extensions 
from the files and restart your server.

## Todo ##

* Standalone mode
	More work is needed on test:acceptance< on Windows to be able to start the server when needed.

* Documentation update


## Not todo ##

* Editor
	Creating an editor for the test cases is currently considered out of scope for this plugin. SeleniumIDE[http://www.openqa.org/selenium-ide/] does such a good  job and has support[http://wiki.openqa.org/display/SIDE/SeleniumOnRails] for both the Selenese and RSelenese formats.

## Credits ##

* Jonas Bengston -- original creator
* Eric Smith, http://blog.8thlight.com/eric -- Current Maintainer
* Jon Tirsen, http://jutopia.tirsen.com -- initial inspiration[http://wiki.rubyonrails.com/rails/pages/SeleniumIntegration]
* Eric Kidd, http://www.randomhacks.net -- contribution of RSelenese
* Marcos Tapajós http://www.improveit.com.br/en/company/tapajos -- Several useful features, current committer
* Ryan Bates, http://railscasts.com -- Fixes for Rails 2.1
* Nando Vieira, http://simplesideias.com.br
* Gordon McCreight, a neat script that lists any unsupported methods

## Contributing ## 

Contributing is simple.  Fork this repo, make your changes, then issue a pull request.  *IMPORTANT* I will not take forks that do not have associated unit tests.  There must be tests, and they must pass, so I can bring the changes in.


## Information ##

For more information, check out the [website](http://seleniumhq.org/projects/on-rails/).
