Tracks: a GTD web application, built with Ruby on Rails
-------------------------------------------------------------

## $LastChangedDate$
## $HeadURL$

# Homepage::  http://www.rousette.org.uk/projects/
# Author::    bsag (http://www.rousette.org.uk/)
# Version::   1.01
# Copyright:: (cc) 2004-2005 rousette.org.uk
# License::   GNU GPL

This is a still a work in progress, and there's almost no error checking or validation of the data yet. Use caution when you run it, and make sure that you back up any important data. Full changenotes can be found in tracks/doc/CHANGENOTES.txt. Full API documentation can be found at tracks/doc/app/index.html.

**IF THIS CRASHES YOUR MACHINE AND LOSES YOUR DATA, IT'S NOT MY FAULT!**

## Installation

Before you start, you need to make sure that you have Ruby 1.8.x, mySQL and Rails 0.9.x. Note particularly the last requirement: this will probably not work with Rails 0.8.x. I have now included RedCloth 3.0 (which allows both Textile and Markdown format in the notes field) in the distribution. Find out more about RedCloth here:
  <http://www.whytheluckystiff.net/ruby/redcloth/>
It's licensed under a BSD license.

1. Unzip tracks.zip somewhere in your home folder ( e.g. /Users/yourusername/Sites).
2. Make a mySQL database called tracks for which you have full access rights.
3. Import the tables and contents using the tracks_dump 03.01.2005.sql file (in tracks/db). If you have previously used the application, export the contents of the tables from your old todo database and import them into the tracks database.
4. Open the tracks/config/database.yml file, and enter your username and password details.
5. Open the tracks/config/setting.yml file, and enter your desired format for dates (see CHANGENOTES.txt for details).
6. Open Terminal and navigate to the todo folder in your Sites folder.
7. Run the command: ruby script/server --environment=production
If you already have the previous GTD application running, make sure that you stop the server, or run Tracks on a different port with ruby script/server --environment=production --port=3030
8. *IMPORTANT* Tracks now has password protection on all the browser accessible files. The first time that you access it, you need to visit <http://127.0.0.1:3000/login/signup>. Choose your username and password, and you will be directed back to the main listing page (<http://127.0.0.1:3000/todo/list>).
9. Have fun!

## Contacting me

I'd love any suggestions you have for improvements, bug-fixes etc. Email me on:
  butshesagirl@rousette.org.uk
 
You can also leave bug reports, feature requests, and comments at:
  <http://www.rousette.org.uk/projects/wiki/>