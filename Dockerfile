FROM ruby:3.3

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

RUN touch /etc/app-env

COPY Gemfile* /app/
RUN gem install bundler
RUN bundle install --jobs 4

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn netcat-openbsd

RUN mkdir /app/log

COPY COPYING /app/
COPY config /app/config/
COPY config/database.docker.yml /app/config/database.yml
COPY config/site.docker.yml /app/config/site.yml

COPY bin /app/bin/
COPY script /app/script/
COPY public /app/public/
COPY vendor /app/vendor/

COPY .yardopts /app/
COPY Rakefile /app/
COPY config.ru /app/
COPY docker-entrypoint.sh /app/

COPY lib /app/lib/
COPY app /app/app/
COPY db /app/db/

COPY .git /app/.git

RUN RAILS_ENV=production bundle exec rake assets:precompile

ENTRYPOINT ["/app/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
