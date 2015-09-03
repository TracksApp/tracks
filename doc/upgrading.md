# Upgrading Tracks

## Upgrading from Tracks 2.3 to 2.4devel

WARNING: 2.4devel is a development tree of Tracks and may (will?) contain bugs that might destroy your data! It is not recommended to upgrade to 2.4devel unless you know what you are doing.

That said. To upgrade:

1. Support for Tracks' older, less secure password-hashing algorithm has been removed. Active user accounts will already have been upgraded, but you should check for outdated accounts by running `bundle exec rake tracks:check_passwords` from your existing Tracks install directory. If any users are listed, they can log in to be prompted to update their passwords, or you can run `bundle exec rake tracks:password USER=<username>` to reset their passwords using the new algorithm. If no users are listed, you can proceed with the upgrade.
2. Back up your existing database and installation of Tracks
3. Install Tracks 2.4devel in a new directory. Or you can create a separate installation of 2.4devel for testing purposes.
4. Copy over the configuration from your previous Tracks installation. If using SQLite3, copy the old database into the new Tracks 2.4devel directory.
5. Check that you have all dependencies installed: `bundle install --without development test` Or leave out the `--without development test` part if you intend to test or develop on this tree.
6. Run `bundle exec rake db:migrate RAILS_ENV=production` to update your old database to the new schema. This is the point of no return. Make sure you have backups!
7. Precompile your static assets (css, javascript, etc.) by running `bundle exec rake assets:precompile RAILS_ENV=production`.
8. Run `bundle exec rails server -e production` inside your Tracks 2.4devel directory to start up Tracks. Or use `-e development` if you intend to try your changes and get more log info.

Please note that if you intend to deploy Tracks using its included web server, you’ll need to copy over the `serve_static_assets` option into your `config/site.yml` and set it as it was in `config/production.rb` in order for the images, stylesheets, and javascript files to be served correctly.

## Upgrading from older versions of Tracks

Upgrade to Tracks 2.3 first. Follow the upgrade instructions included in Tracks 2.3.
