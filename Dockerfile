ARG RUBY_VERSION=3.3
FROM ruby:${RUBY_VERSION} AS base

WORKDIR /app
RUN touch /etc/app-env

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn netcat-openbsd
RUN gem install bundler

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

# Use glob to omit error if the .git directory doesn't exists (in case the
# code is from a release archive, not a Git clone)
COPY .gi[t] /app/.git

COPY Gemfile* /app/

ENTRYPOINT ["/app/docker-entrypoint.sh"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

FROM base AS precompile
RUN bundle config set with assets
RUN bundle config set deployment true
RUN bundle install --jobs 4
RUN RAILS_GROUPS=assets bundle exec rake assets:precompile

# Build the environment-specific stuff
FROM base AS production
RUN bundle config --global frozen 1
RUN bundle install --jobs 4
COPY --from=precompile /app/public/assets /app/public/assets

FROM base AS test
COPY test /app/test/
# For testing the API client
COPY doc /app/doc/
RUN bundle config set with development test assets
RUN bundle config --global frozen 1
RUN bundle install --jobs 4
RUN RAILS_GROUPS=assets bundle exec rake assets:precompile

FROM base AS development
RUN bundle config set with development test
RUN bundle install --jobs 4
