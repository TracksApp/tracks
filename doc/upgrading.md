# Upgrading Tracks

## Upgrading from Tracks 2.2.x to 2.3.0

To upgrade:

1. Back up your existing database and installation of Tracks
2. Install Tracks 2.3.0 in a new directory. Or you can create a separate installation of 2.3.0 for testing purposes.
3. Copy over the configuration from your previous Tracks installation. If using SQLite3, copy the old database into the new Tracks 2.3.0 directory.
4. Check that you have all dependencies installed: `bundle install --without development test` Or leave out the `--without development test` part if you intend to test or develop on this tree.
5. Run `bundle exec rake db:migrate RAILS_ENV=production` to update your old database to the new schema. This is the point of no return. Make sure you have backups!
6. Precompile your static assets (css, javascript, etc.) by running `bundle exec rake assets:precompile RAILS_ENV=production`.
7. Run `bundle exec rails server -e production` inside your Tracks 2.3.0 directory to start up Tracks. Or use `-e development` if you intend to try your changes and get more log info.

Please note that if you intend to use Tracks with the built in webserver called WEBrick for production, you’ll need to change `config.serve_static_assets` to `true` in `config/environments/production.rb` in order for the images, stylesheets, and javascript files to be served correctly.

The Czech locale has been renamed from `cz` to `cs` in accordance with ISO standards. Users of the Czech locale will need to edit their preferences and reselect the locale under the new name.

## Upgrading from older versions of Tracks

Upgrade to Tracks 2.2.3 first. Follow the upgrade instructions included in Tracks 2.2.3.
