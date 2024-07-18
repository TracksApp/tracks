# Installing Tracks

Tracks can be installed several ways: You can run it through Docker, which is recommended because all requirements have already been taken care of for you, or you can install it on a custom server from source.

Community-provided instructions for other options and tips for specific environments are available in the Tracks wiki: https://github.com/TracksApp/tracks/wiki/Installation.

## Docker installation using Docker Compose

You can easily run Tracks using Docker Compose. This option mounts the repository directly inside the Docker container, making it an optimal solution for developing Tracks. It does, however, also work for normal users.

1. Make sure you have Docker Compose and Docker properly installed.
2. Get the Tracks code base by either downloading the archive file for the latest releast or cloning it from GitHub.
3. Create a file to enable the Docker Compose support in Tracks. *Note*: This is not needed or useful for the separate container, only Docker Composer!
```
   $ touch .use-docker
```
4. On the installation run the following command:
```
   $ ./script/setup
```
5. Run the server using the following command:
```
   $ ./script/server
```
6. You should now be able to access Tracks in http://localhost:3000

Note: If you've previously used the Tracks docker-compose installation with a
directory of the same name, the old database might still exist which prevents
it from being re-initialised. If you want to start from scratch, check out the
volume list and remove the volume in question with the following commands:

```
$ docker volume list
$ docker volume rm tracks_db-data
```

## Docker installation using a separate container

You can also install Tracks without Docker Compose. This allows you to use the official Docker containers and you can use your existing database server instead of having a separate one for Tracks.

*Note*: For now, you have to first build the image manually before starting the
Tracks container. In future there should be an official image in Docker Hub. You can build the image by:

1. Get the Tracks code base by either downloading the archive file for the latest releast or cloning it from GitHub.
2. Run the following command in the Tracks directory to build the image:
```
   $ docker build -t="tracks" .
```

1. Make sure you have Docker properly installed.
2. Start a database container with either MySQL or PostgreSQL:
```
   $ docker run -d -p 5432:5432 --name postgres -e POSTGRES_PASSWORD=password -d postgres
   $ docker run -d -p 3306:3306 --name mariadb -e MYSQL_ROOT_PASSWORD=password -d mariadb
```
3. Create a database and a user for Tracks in the database:
```
   # MySQL
   $ mysql -u root -p
   mysql> CREATE DATABASE tracks;
   mysql> GRANT ALL PRIVILEGES ON tracks.* TO yourmysqluser@'%' IDENTIFIED BY 'password-goes-here' WITH GRANT OPTION;

   # PostgreSQL
   $ sudo -u postgres psql
   postgres=# CREATE USER tracks WITH ENCRYPTED PASSWORD 'password-goes-here';
   postgres=# CREATE DATABASE tracks OWNER=tracks;
```
4. Install the schema
```
   $ docker run --link mariadb:db --rm -t tracks bin/rake db:reset
   $ docker run --link postgres:db --rm -t tracks bin/rake db:reset
```
5. Start the Tracks server:
```
   $ docker run -d -p 3000:3000 --name tracks --link mariadb:db -t tracks
   $ docker run -d -p 3000:3000 --name tracks --link postgres:db -t tracks
```
6. You should now be able to access Tracks in http://localhost:3000

## Environmental variables in the Docker image

You can override database connection details by defining the environment variables in the run command, for example ”-e DATABASE_USERNAME=tracks_dev” or docker-compose.yml, if using Docker Compose.

|Name              |Default    |For PostgreSQL      |
|------------------|-----------|--------------------|
|DATABASE_NAME     |tracks     |                    |
|DATABASE_HOST     |db         |                    |
|DATABASE_PORT     |3306       |5432                |
|DATABASE_USERNAME |tracks     |                    |
|DATABASE_PASSWORD |password   |                    |
|DATABASE_TYPE     |mysql2     |postgresql          |
|DATABASE_ENCODING |utf8       |unicode             |
|RAILS_ENV         |production |                    |
|BUNDLE_WITHOUT    |           |Gem classes to omit |

### Override files

You can override files in the Docker image by using the --volume argument or docker-compose.yml, if using Docker Compose.

|File               |Argument                                                 |Replace for production?|
|-------------------|---------------------------------------------------------|-----------------------|
|config/site.yml    |--volume /app/config/site.yml:/home/user/site.yml        |Yes                    |

## Custom server installation

This description is intended for people installing Tracks from scratch. If you would like to upgrade an existing installation, please see the [upgrade documentation](upgrading.md).

### Prerequisites

Tracks has a few software requirements that must be satisfied before installation:

1. **Ruby**. Tracks requires Ruby 2.5 or greater. Most of the testing is done with 2.6.
2. **Bundler**. Tracks requires a recent version of [Bundler](http://bundler.io) to handle the installation of dependencies. Bundler is typically installed by running `gem install bundler`.
3. **Database**. Tracks is tested on [MySQL](http://www.mysql.com/) and [SQLite](http://www.sqlite.org/), but [PostgreSQL](http://www.postgresql.org/) can also be used. Of the three, SQLite requires the least configuration but is also the least performant and may make it difficult to operate in the future. We recommend either MySQL or PostgreSQL. Whatever your choice, the appropriate database software must be installed.

### Get Tracks

There are two methods of downloading Tracks:

1. (Recommended for most people) Download an archive of [the latest stable release](https://github.com/TracksApp/tracks/releases/latest) and extract it to your preferred location (e.g. `~/Sites` for Mac OS X users).
2. If you want to live on the edge, you can get the latest development version from GitHub using git (bear in mind that this may be less stable than the released versions):

<!-- -->

    cd ~/Sites
    git clone https://github.com/TracksApp/tracks.git
    cd tracks

### Set up the database

*This section doesn't apply if using SQLite.*

You need to create a database and database-user to use with Tracks. For this, you can use an GUI tool or go into a terminal and issue the following commands:

#### MySQL

    $ mysql -u root -p
    mysql> CREATE DATABASE tracks;
    mysql> GRANT ALL PRIVILEGES ON tracks.* TO yourmysqluser@localhost \
    IDENTIFIED BY 'password-goes-here' WITH GRANT OPTION;

#### PostgreSQL

    $ sudo -u postgres psql
    postgres=# CREATE USER tracks WITH ENCRYPTED PASSWORD 'password-goes-here';
    postgres=# CREATE DATABASE tracks OWNER=tracks;

### Install dependencies

Tracks is built upon a number of Ruby libraries (known as ‘gems’). The Bundler tool makes it easy to install all the gems that Tracks needs, and ensures that they are all the correct versions.

1. In the directory that you unzipped your Tracks download to, install all the appropriate gems by running:
  * If you are using SQLite:

        ```
        bundle config set without "development test mysql"
        bundle install
        ```

  * If you are using MySQL:

        ```
        bundle config set without "development test sqlite"
        bundle install
        ```
  
  * If you are using PostgreSQL:

        ```
        bundle config set without "development test sqlite mysql"
        bundle install
        ```

  * If you are installing Tracks on Windows or Mac OS X, or if you have another JavaScript runtime such as Node.js installed, you may also append `therubyracer` as an additional "without" parameter.
2. Wait for Bundler to finish installing the necessary gems that Tracks needs. This can take some time depending on the speed of your internet connection and the speed of the system you’re installing Tracks on.

## Configure variables

1. In the `config` folder, copy the files `database.yml.tmpl` and `site.yml.tmpl` to `database.yml` and `site.yml`, respectively.
2. Open the file `config/database.yml` and edit the `production:` section with the details of your database.
   * If you are using MySQL the `adapter:` line should read `adapter: mysql2`, `host: localhost` (in the majority of cases), and your username and password should match those you assigned when you created the database. 
   * If you are using PostgreSQL, set the line to `adapter: postgresql` and adjust host, username and password as appropriate.
   * If you are using SQLite3, you should have only two lines under the production section: `adapter: sqlite3` and `database: db/tracks.db`.
5. Open the file `config/site.yml`, and read through the settings to make sure that they suit your setup. In most cases, all you need to change are the `secret_token`, the administrator email address (`admin_email`), and the time zone setting. For the time zone setting you can use the command `bundle exec rake time:zones:local` to see all available timezones on your machine
6. If you are using Windows, you may need to check the ‘shebang’ lines (`#!/usr/bin/env ruby`) of the `/public/dispatch.*` files and all the files in the `/script` directory. They are set to `#!/usr/bin/env ruby` by default. This should work for all Unix based setups (Linux or Mac OS X), but Windows users will probably have to change it to something like `#c:/ruby/bin/ruby` to point to the Ruby binary on your system.
7. If you intend to use Tracks behind a web server or reverse proxy with https enabled, ensure to set `force_ssl` option to `true`.

### Populate your database with the Tracks schema

Open a terminal and change into the root of your Tracks directory. Enter the following command:

    bundle exec rake db:migrate RAILS_ENV=production

This will set up your database with the required structure to hold Tracks’ data.

### Precompile assets

Static assets (images, stylesheets, and javascript) need to be compiled in order for them to work correctly with the new asset pipeline feature in Rails. Precompiling your assets is as simple as running the following command while inside the Tracks root directory:

    bundle exec rake assets:precompile RAILS_ENV=production

### Start the server

While still in the Terminal inside the Tracks root directory, issue the following command:

    RAILS_SERVE_STATIC_FILES=TRUE bundle exec rails server -e production

If all goes well, you should see some text informing you that the server is running: `=> Rails application starting in production on http://localhost:3000`. If you are already running other services on port 3000, you need to select a different port when running the server, using the `-p` option.

Optimally you should serve static files using Nginx or Apache, especially in larger production instances. If you do this, you can omit the RAILS_SERVE_STATIC_FILES=TRUE from the start of the command.

### Visit Tracks in a browser

Visit `http://localhost:3000/signup` in a browser (or whatever URL and port was reported when you started the server in the step above) and chose a user name and password for admin user. Once logged in as admin, you can add other (ordinary level) users. If you need to access Tracks from a mobile/cellular phone browser, visit `http://yourdomain.com/mobile/`. This mobile version is a special, lightweight version of Tracks, designed to use on a mobile browser.

### Customise Tracks

Once logged in, add some Contexts and Projects, and then go ahead and add your actions. You might also want to visit the Preferences page to edit various settings to your liking. Have fun!
