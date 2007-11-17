Title: Upgrading to Tracks 1.5
Author: Tracks Development Team
Date: 2007-11-17
Format: Complete
CSS: manual.css

<!-- The HTML file upgrading.html is generated from upgrading.markdown, so make edits to upgrading.markdown -->

# Upgrading to Tracks 1.5 #

**NB: THIS IS A WORK IN PROGRESS - LINKS AND SVN URLS MENTIONED MAY NOT BE ACTIVE YET.**

**TODO: Instructions for upgrading from a version earlier than 1.043**

## Upgrading from Tracks 1.043 ##

This should be a relatively straightforward, and involves the following main steps:

1. [Back up][backup] your existing database and installation of Tracks
2. [Install Tracks 1.5][install1.5] in a new directory
3. [Copy over][config] a few configuration files from your Tracks 1.043 directory. If using SQLite3, copy the old database into the new Tracks 1.5 directory
5. Run `rake db:migrate RAILS_ENV=production` to [update your old database][rake] to the new schema -- you did back up your database didn't you?
6. Run `script/server` inside your Tracks 1.5 directory to [start up Tracks 1.5][startserver].
7. Once you are happy that everything is working well, [delete your old Tracks directory][cleanup].

### Backing up [backup] ###

It's very important that you **back up your database** before you start the upgrade process. It's always possible for things to go wrong with the database update, and you don't want to lose any data. If you are using SQLite3 and you are leaving your old Tracks directory in place, then you don't need to do anything. However, there is no harm in taking extra precautions and copying your database from `/db` to a safe location as an extra backup, or making a dump of the schema and contents. You will never regret making too many backups! If you are using MySQL, make a SQL dump of your database, replacing the terms in square brackets with the correct information for your setup:

`mysqldump –-user [user name] –-password=[password] [database name] > [dump file]`

Rename your old Tracks installation (e.g. to 'tracks-old') so that you can install Tracks 1.5 along side it.

### Install Tracks 1.5 [install1.5] ###

There are two methods of downloading Tracks 1.5:

1. (Recommended for most people) Download the [zipped package](http://www.rousette.org.uk/projects/files/tracks-current.zip), and unzip in your preferred location (e.g. `~/Sites` for Mac OS X users).
2. Download using Subversion:
`svn co --username=guest http://www.rousette.org.uk/svn/tracks-repos/tags/current tracks`

### Copy over old configuration files [config] ###

There are a few files you need to copy over from your old installation. If you copy them over rather than moving them, you can still run your old version of Tracks if anything goes awry with the installation process.

1. Copy `/config/database.yml` from your old Tracks directory to the same location in the new one. Double check that the information there is still correct.
2. Duplicate `/config/environment.rb.tmpl` in the Tracks 1.5 directory, and rename the file to `environment.rb`. Open the file and alter the line `SALT = "change-me"` so that it matches what you had in this file in your old installation. You may also want to change the time zone setting as appropriate for your location (`ENV['TZ'] = 'US/Eastern'`). If you have made any other customisations to `environment.rb` in the past, copy those over, but the contents of the file have changed quite a lot since 1.043, so check it carefully.
3. Copy your `/log` directory over from your old installation to the root of the new one, or just rename `/log.tmpl` to `log` to start afresh.
4. If you are using SQLite3, copy your database from `/db` in your old Tracks directory to the same location in the new one.
5. If you are using Windows, you may need to check that the 'shebang' lines (`#!/usr/bin/env ruby`)[^env] in many of the files in `/script` directory are correct for your environment. Check the format of those lines in your old installation, and change the new ones as necessary.

### Update your old database to the new format [rake] ###

In a terminal, change directories so that you are inside the Tracks 1.5 directory. Then issue the command:

`rake db:migrate RAILS_ENV=production`

Watch the output carefully for errors, but it should report at the end of the process that everything worked OK. If you do get errors, you'll have to fix them before you proceed any further. Running rake with the `--trace` option can help to track down the problem.

### Start the server [startserver] ###

If you're still in the Tracks 1.5 root directory in a terminal, enter the following command to start up Tracks in production mode:

`script/server -e production`

Visit the URL indicated by the output (e.g. `** Mongrel available at 0.0.0.0:3000`
) in a browser, and with any luck, you should be able to log in and find all your actions as you left them!

### Clean up your old installation [cleanup] ###

Once you're certain that your new Tracks 1.5 installation is working perfectly, you can delete your old Tracks directory.

[^env]: The `env` binary helps to locate other binaries, regardless of their location. If you don't have `env` installed, you'll need to change this line to point to the location of your Ruby binary.