Tracks: a GTD web application, built with Ruby on Rails
-------------------------------------------------------------

# Homepage::  http://www.rousette.org.uk/projects/
# Author::    bsag (http://www.rousette.org.uk/)
# Version::   1.02
# Copyright:: (cc) 2004-2005 rousette.org.uk
# License::   GNU GPL

This is a still a work in progress; use caution when you run it, and make sure that you back up any important data. Full changenotes can be found in tracks/doc/CHANGENOTES.txt. Full API documentation can be found at tracks/doc/app/index.html.

**IF THIS CRASHES YOUR MACHINE AND LOSES YOUR DATA, IT'S NOT MY FAULT!**

## Installation

Before you start, you need to make sure that you have Ruby 1.8.2, mySQL and Rails 0.10.0. Note particularly the last requirement: this version *requires* Rails 0.10.0, or the re-writing of URLs will not work. In fact, the whole app will not work ;-). I have now included RedCloth 3.0.3 (which allows both Textile and Markdown format in the notes field) in the distribution. Find out more about RedCloth here:
  <http://www.whytheluckystiff.net/ruby/redcloth/>
It's licensed under a BSD license. There's an odd error which pops up when using Redcloth from the lib directory in the application, but only when you are running under the development environment. To get around this, I've set environment.rb to look for a gem version of Redcloth first and use that, and only then fall back on the included version (see CHANGENOTES.txt for details).

### New users

1. Unzip tracks_1_02.zip somewhere in your home folder ( e.g. /Users/yourusername/Sites).
2. Make a mySQL database called tracks for which you have full access rights.
3. Import the tables and contents using the tracks_1.0.2_tables_mysql.sql and tracks_1.0.2_content_mysql.sql files (in tracks/db). If you don't want to start with dummy next actions in your database, simply delete everything from the line:
  # Dump of table todos
to the end of the tracks_1.0.2_content_mysql.sql file.
4. Open the tracks/config/database.yml file, and enter your username and password details.
5. Open the tracks/config/setting.yml file, and enter your desired format for dates and your email address for the login/signup page (see CHANGENOTES.txt for details).
6. Open Terminal and navigate inside the tracks folder (e.g. cd /Users/yourusername/Sites/tracks).
7. Run the command: ruby script/server --environment=production
*IMPORTANT* If you already have an application running on WEBrick (Tracks or anything else), make sure that you stop the server, or run Tracks on a different port with ruby script/server --environment=production --port=3030
8. In a browser, go to http://127.0.0.1:3000/login/signup. This will allow you to choose a username and password for the admin user. Thereafter, anyone else trying to access login/signup will get a message that they are not allowed to sign up, and are given your email address to contact for permission. When you are logged in as the admin user, you can visit login/signup to sign up additional users. Note that Tracks isn't truly multi-user: all your users will be able to view (and edit) your data. The login system is just to restrict access to your sensitive data.
9. Have fun!

### Upgrading

1. Before you do anything else, BACK UP YOUR DATABASE (tables and content). Then make a separate export of the contents only (assuming that you want to move your data to the new version.)
2. In your contents export, delete the contents of the Users table. There are new fields in the users table, and it would be best to create your users again from scratch from the login/signup page.
3. For safety, rename your current Tracks directory to 'tracks-old' or something similar, and if you are able, create a new database for the new version. If you can't create a new database, delete the contents and tables in your old one MAKING SURE THAT YOU HAVE BACKED UP YOUR DATABASE AS IN STEP 1 FIRST.
4. Import first tracks_1.0.2_tables_mysql.sql from tracks/db, then your own contents dump file into the new database.
5. Fill in the correct details in database.yml and settings.yml, referring to the old copies in tracks-old if necessary.
6. From here, follow steps 6-9 for new users above. Don't forget that as you've deleted your users table, you'll need to re-create your users via login/signup.


## Using databases other than MySQL

Rick Bradley kindly converted the MySQL schema for Tracks to Postgresql format, so I was able to use that as a model for the new version - see tracks/db/tracks_1.0.2_postgres.sql. Remember that you'll also need to change the adapter line in database.yml:
  adapter: postgresql

If you use SQLite, you could try the schema tracks/db/tracks_1.0.2_sqlite.sql, but note that it is untested. You also need to alter database.yml a little:
  adapter: sqlite
  dbfile: ../db/tracks.db

Substitute your real SQLite database name for tracks.db above.


## Other servers

WEBrick is the easiest server to get working to test out Tracks, and will be fine if you have Tracks installed on your own machine. One nice feature in Rails 0.10.0 is that WEBrick runs by default on the IP address 0.0.0.0, which means that you can access it via 127.0.0.1 when you are on the same machine, or via the external IP address of the machine running Tracks, so long as you can access the network of that machine from your current location. However, it is possible to use other servers, and the new re-writing rules of Rails 0.10.0 ('Routes' in environment/routes.rb) mean that very little configuration is needed.

### Apache

See the file tracks/README_RAILS for an example of an Apache conf. The file tracks/public/.htaccess contains the necessary re-write rules to call dispatch.cgi or dispatch.fcgi. All other rules are handled by routes.rb

### Lighttpd

Again, see tracks/README_RAILS for a working example of a lighttpd.conf file. Note that you'll want to change the line:
  "bin-environment" => ( "RAILS_ENV" => "development" 

to
  "bin-environment" => ( "RAILS_ENV" => "production"
   

## Contacting me

I'd love any suggestions you have for improvements, bug-fixes etc. Email me on:
  butshesagirl@rousette.org.uk
 
You can also leave bug reports, feature requests, and comments at:
  <http://www.rousette.org.uk/projects/wiki/>