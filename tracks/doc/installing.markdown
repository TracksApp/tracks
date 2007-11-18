Title: Installing Tracks 1.5
Author: Tracks Development Team
Date: 2007-11-18
Format: Complete
CSS: manual.css

<!-- The HTML file installing.html is generated from installing.markdown, so make edits to installing.markdown -->

# Installing Tracks 1.5 #

## Introduction ##

Tracks 1.5 has been thoroughly beta tested by a large number of people, and should be fully stable for everyday use. However, once set up, Tracks will contain the majority of your plans for your work and personal life, so it's only sensible to make sure that you have frequent, reliable backups of your data. Full changenotes on the release can be found in `doc/CHANGELOG`. Full API documentation can be found at `doc/app/index.html`, once you have run `rake appdoc`

There are two methods of downloading Tracks 1.5:

1. (Recommended for most people) Download the [zipped package](http://www.rousette.org.uk/projects/files/tracks-current.zip), and unzip in your preferred location (e.g. `~/Sites` for Mac OS X users).
2. Download using Subversion:
`svn co --username=guest http://www.rousette.org.uk/svn/tracks-repos/tags/current tracks`

## Requirements ##

The Tracks interface is accessed through a web browser, so you need to run a webserver to serve the Tracks pages up to you. This isn't as daunting as it sounds, however: Tracks ships with a built-in web server called Mongrel which you can run on your own computer to serve the Tracks application locally. If you want to be able to access Tracks from any computer connected to the Internet, then you need to install Tracks on a publicly accessible server, and you will probably be better off using a more robust server such as [Apache](http://www.apache.org/) or [Lighttpd](http://www.lighttpd.net/) to serve the pages, particularly if it will be used by many people.

Tracks stores its data in a database, and you can either use SQLite3, MySQL or PostgreSQL. SQLite3 is the best choice for a single user (or a small number of users) on a local installation, while MySQL or PostgreSQL is better for multiple users on a remote installation.

### All in one installations ###

This is the easiest solution for Mac OS X 10.4 or Windows users wanting to run Tracks locally.

1. **Mac OS X**. [Locomotive](http://locomotive.sourceforge.net/) is an all-in one installer for Mac OS X 10.4, which includes everything you need to run Tracks with a SQLite3 database. Locomotive isn't currently Leopard compatible, and doesn't work with Panther.
2. **Windows**. [Instant Rails](http://instantrails.rubyforge.org/wiki/wiki.pl) includes everything you need, including MySQL.

### What is included with the Tracks package ###

1. Tracks itself
2. Rails 1.2.5 (installed in the `/vendor/rails` directory, so you do not need to install Rails yourself)
3. An empty SQLite3 database, set up with the correct database schema

### What you need to install [whatyouneed] ###

If you don't want to (or can't) use one of the all in one installations, you'll need to install a few things, depending on your platform and your needs.

1. **Ruby**. Version 1.8.6 is recommended, but it is also possible to use 1.8.5, 1.8.4 and 1.8.2. Note that 1.8.3 is not compatible. If you are running Mac OS X Leopard, you already have Ruby 1.8.6 installed by default, so you have nothing to do here. You can get the source to compile yourself [here](http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6.tar.gz) for all platforms, or Windows users can use an easy [installer](http://rubyforge.org/frs/?group_id=167). If you're using a version of Mac OS X earlier than 10.5.0, it is recommended that you use the [instructions here](http://hivelogic.com/narrative/articles/ruby-rails-mongrel-mysql-osx) to install all the Rails dependencies, though you can skip the step to install Rails if you like.
2. **RubyGems**. The gems needed by Rails to interact with the database have to be compiled on the platform on which they will be run, so we cannot include them with the Tracks package, unlike some other gems. So you will need to [download](http://rubyforge.org/frs/?group_id=126) and install RubyGems (run `ruby setup.rb` after extracting the package). Note that once again, Mac OS X Leopard users get an easy life, because RubyGems and the SQLite3 gem is already installed. Once installed you can use RubyGems to install the gems you need for your database. If you are using SQLite3, run `sudo gem install sqlite3-ruby`, then select the appropriate package for your platform (version 1.2.1 recommended). You can use MySQL without installing a gem, but installing the gem can speed things up a bit: `sudo install gem mysql`. If you're using Leopard, there are a few work-arounds necessary, which are explained on [Mac OS Forge](http://trac.macosforge.org/projects/ruby/wiki/Troubleshooting#IcannotbuildrubymysqlonLeopardwithmysql.combinaries). The ruby-mysql bindings can sometimes be a bit troublesome to install, so to be honest, it's probably not worth the bother unless you are trying to wring maximum speed out of your system. If you are using PostgreSQL, then you can install a postgres gem: `gem install postgres`.
3. **Database**. The easiest option is to use SQLite3, as the database is included in the package. All you need then is the `sqlite3-ruby` gem, as described in step 2, and the SQLite3 libraries and binary (see [sqlite.org](http://sqlite.org/download.html) for downloads and installation instructions). If you want to use MySQL, download and install a package for your platform from [MySQL.com](http://dev.mysql.com/downloads/mysql/5.0.html). The basic steps for Postgresql should be similar to those for MySQL, but they will not be discussed further here.

## Installation ##


1. [Unzip tracks][unzip] and install in a directory
2. Decide on a [database][database] to use
  1.  SQLite3 - change database.yml to point to SQLite3 database
  2.  MySQL - create new MySQL db and grant all privs
3. [Configure some variables][config]
4. Populate the database with the [Tracks 1.5 schema][rake]
5. [Start the server][startserver]
6. [Visit Tracks in a browser][signup]
7. [Customise Tracks][customise]

### Unzip Tracks and install [unzip] ###

Unzip the package and move Tracks into the directory you want to run it from. For example, for Mac OS X users, `~/Sites` is a good choice.

### Decide on a database [database] ###

Before you go any further, you need to decide which database you will use. See the [What you need to install][whatyouneed] section for details on installing the required components for you choice of database.

1. **SQLite3**. All you need to do is make sure that you point Tracks to the included SQLite3 database in `/db` in the next step, [Configure variables][config].
2. **MySQL**. Once you have MySQL installed, you need to create a database to use with Tracks 1.5. Go into a terminal and issue the following commands:
<pre>
<code>
    mysql -uroot -p
    mysql> CREATE DATABASE tracks15;
    mysql> GRANT ALL PRIVILEGES ON tracks15.* TO yourmysqluser@localhost \
    IDENTIFIED BY 'password-goes-here' WITH GRANT OPTION;
</code>
</pre>

### Configure variables [config] ###

1. Open the file `/config/database.yml` and edit the `production:` section with the details of your database. If you are using MySQL the `adapter:` line should read `adapter: mysql`, `host: localhost` (in the majority of cases), and your username and password should match those you assigned when you created the database. If you are using SQLite3, you should have only two lines under the production section: `adapter: sqlite3` and `database: db/tracks-15.db`.
2. Open the file `/config/environment.rb`, and read through the settings to make sure that they suit your setup. In most cases, all you need to change is the `SALT = "change-me"` line (change the string "change-me" to some other string of your choice), and the time zone setting.
3. If you downloaded Tracks 1.5 via Subversion, you need to duplicate the files `database.yml.tmpl` and `environment.yml.tmpl` and remove the `*.tmpl` extension from the duplicates. Similarly, duplicate `/log.tmpl` and remove the `*.tmpl` extension, then edit the files as described in steps 1 and 2 above.
4. If you are using Windows, you may need to check the 'shebang' lines (`#!/usr/bin/env ruby`) of the `/public/dispatch.*` files and all the files in the `/script` directory. They are set to `#!/usr/bin/env ruby` by default. This should work for all *nix based setups (Linux or Mac OS X), but Windows users will probably have to change it to something like `#c:/ruby/bin/ruby` to point to the Ruby binary on your system.

### Populate your database with the Tracks 1.5 schema [rake] ###

Open a terminal and change into the root of your Tracks 1.5 directory. Enter the following command:

`rake db:migrate RAILS_ENV=production`

This will update your database with the required schema for Tracks 1.5. If you are using SQLite3, it is not strictly necessary, because the SQLite3 database included with Tracks already has the schema included in it, but it should not do any harm to run the command (nothing will happen if it is up to date).

### Start the server [startserver] ###

While still in the Terminal inside the Tracks 1.5 root directory, issue the following command:

`script/server -e production`

If all goes well, you should see some text informing you that the Mongrel server is running: `** Mongrel available at 0.0.0.0:3000`. If you are already running other services on port 3000, you need to select a different port when running the server, using the `-p` option. You can stop the server again by the key combination Ctrl-C.

### Visit Tracks in a browser [signup] ###

Visit `http://0.0.0.0:3000/signup` in a browser (or whatever URL and port was reported when you started the server in the step above) and chose a user name and password for admin user. Once logged in as admin, you can add other (ordinary level) users.

### Customise Tracks [customise] ###

Once logged in, add some Contexts and Projects, and then go ahead and add your actions. You might also want to visit the Preferences page to edit various settings to your liking. Have fun!
