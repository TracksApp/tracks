The main README file is in tracks/doc/README_FOR_APP, and the change log in tracks/doc/CHANGELOG.

** IMPORTANT **

Before you do anything else, you need to copy the following file and rename the copy:

  tracks/config/database.yml.tmpl -> tracks/config/database.yml
  
You need to put your settings into database.yml. Just leave the .tmpl versions as they are. I'm sorry to impose this extra step, but it's important for the subversion repository not to have your super-seekrit MySQL database user name and password checked in to the repository for all to see!