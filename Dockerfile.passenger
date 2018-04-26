FROM phusion/passenger-ruby22:0.9.18

WORKDIR /home/app/tracks

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test mysql therubyracer --jobs=3

# Install and configure the app
ENV RAILS_ENV=production
ENV DATABASE_URL=sqlite3:/var/tracks/database.sqlite3
RUN mkdir /var/tracks && chmod 777 /var/tracks
RUN touch /var/tracks/database.sqlite3 && chown app.app /var/tracks/database.sqlite3
COPY . ./
COPY config/site.yml.tmpl /etc/tracks/config/site.yml
RUN ln -sf /etc/tracks/config/site.yml config/site.yml
RUN bundle exec rake assets:precompile
RUN chown -R app.app .

# Configure nginx
RUN echo "env DATABASE_URL;" > /etc/nginx/main.d/env.conf
RUN echo "\
server {\n\
    listen 80 default_server;\n\
    server_name _;\n\
    root /home/app/tracks/public;\n\
    passenger_enabled on;\n\
    passenger_user app;\n\
    passenger_ruby /usr/bin/ruby2.2;\n\
}" > /etc/nginx/sites-enabled/tracks.conf
RUN rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down

# Migrate the database on startup
RUN echo "#!/bin/sh\nbundle exec rake db:migrate" > /etc/my_init.d/90_tracks.sh
RUN chmod +x /etc/my_init.d/90_tracks.sh

VOLUME ["/etc/tracks", "/var/tracks"]

# Default command for baseimage-docker
CMD ["/sbin/my_init"]
