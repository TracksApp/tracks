# Upgrading Tracks

## General upgrade instructions

* Remember to always backup your database before upgrading! Test before
  upgrading production environments.

* For information regarding installation see doc/installation.md.

* Make sure to run database migrations using one one of the following:
```
   # For pure (Dockerless) installation:
   $ rake db:migrate

   # For Docker Compose installation:
   $ bin/rake db:migrate

   # For separate Docker container installation either one of:
   $ docker run --link mariadb:db --rm -t tracks bin/rake db:migrate
   $ docker run --link postgres:db --rm -t tracks bin/rake db:migrate
```

## Upgrading from Tracks 2.4.2 to 2.5.0

* If you're using the Docker Compose environment and want to run the commands in
  the bin/ directory inside the container from the host system, add a .use-docker
  file to the root directory. This replaces the old .skip-docker file requirement
  to favor the more common setup and avoid placing unexpected requirements.

* The Docker environment has been changed quite a bit. However, it should work
  at least as before for the usual needs.

## Upgrading from Tracks 2.3 to 2.4.2

These upgrade instructions are rough. Please suggest improvements in a GitHub issue if you run into problems.

To upgrade:

1. Support for Tracks' older, less secure password-hashing algorithm has been removed. Active user accounts will already have been upgraded, but you should check for outdated accounts by running `bundle exec rake tracks:check_passwords` from your existing Tracks install directory. If any users are listed, they can log in to be prompted to update their passwords, or you can run `bundle exec rake tracks:password USER=<username>` to reset their passwords using the new algorithm. If no users are listed, you can proceed with the upgrade.
2. Back up your existing database and installation of Tracks
3. Install Tracks 2.4.0 in a new directory. Or you can create a separate installation of 2.4.0 for testing purposes.
4. In order to use the application out of a container environment (the pre-2.4 default), `touch .skip-docker` in the application directory.
5. Copy over the configuration from your previous Tracks installation. If using SQLite3, copy the old database into the new Tracks 2.4.0 directory.
6. Check that you have all dependencies installed: `bundle install --without development test` Or leave out the `--without development test` part if you intend to test or develop on this tree.
7. Run `bundle exec rake db:migrate RAILS_ENV=production` to update your old database to the new schema. This is the point of no return. Make sure you have backups!
8. Precompile your static assets (css, javascript, etc.) by running `bundle exec rake assets:precompile RAILS_ENV=production`.
9. Run `bundle exec rails server -e production` inside your Tracks 2.4.0 directory to start up Tracks. Or use `-e development` if you intend to try your changes and get more log info.

Please note that if you intend to deploy Tracks using its included web server, you’ll need to copy over the `serve_static_assets` option into your `config/site.yml` and set it as it was in `config/production.rb` in order for the images, stylesheets, and javascript files to be served correctly.

## Upgrading from older versions of Tracks

Upgrade to Tracks 2.3 first. Follow the upgrade instructions included in Tracks 2.3.
