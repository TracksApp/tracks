The main README file is in tracks/doc/README_FOR_APP, and the change log in tracks/doc/CHANGELOG. If you downloaded this application as a *.zip file, then there is documentation for the app in tracks/doc/app. If you open the index.html file in a browser, you can view the documentation for the methods, as well as viewing README_FOR_APP and CHANGELOG in more attractive format. If you checked out the application with Subversion, you need to generate the documentation. Navigate inside the tracks directory in a terminal, then issue the following command:
  rake appdoc
  
This will generate the documentation as above in tracks/doc/app.

Database schemas for MySQL, PostgreSQL and SQLite are available in tracks/db, along with some example contents in tracks_1.0.3_content.sql.

** IMPORTANT **

Before you do anything else, you need to copy certain files and rename the copy:

  tracks/config/database.yml.tmpl -> tracks/config/database.yml
  tracks/config/settings.yml.tmpl -> tracks/config/settings.yml
  tracks/log.tmpl                 -> tracks/log
  
You need to put your settings into database.yml and settings.yml. Just leave the .tmpl versions as they are. I'm sorry to impose this extra step, but it's important for the subversion repository not to have your super-seekrit MySQL database user name and password checked in to the repository for all to see!