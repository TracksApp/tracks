The main README.txt file is in tracks/doc/README.txt, and the change log in tracks/doc/CHANGENOTES.txt.

The database structure dump file (with some test contents) is in tracks/db/tracks_dump 03.01.2005.sql, which you can import into your database.

** IMPORTANT **

Before you do anything else, you need to copy certain files and rename the copy:

  tracks/config/database.yml.tmpl -> tracks/config/database.yml
  tracks/config/settings.yml.tmpl -> tracks/config/settings.yml
  tracks/log.tmpl                 -> tracks/log
  
You need to put your settings into database.yml and settings.yml. Just leave the .tmpl versions as they are. I'm sorry to impose this extra step, but it's important for the subversion repository not to have your super-seekrit MySQL database user name and password checked in to the repository for all to see!