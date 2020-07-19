FROM ruby:2.6

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile* /app/
RUN gem install bundler
RUN bundle install --jobs 4

RUN mkdir /app/log

COPY . /app/
COPY config/database.docker.yml /app/config/database.yml
COPY config/site.docker.yml /app/config/site.yml

RUN RAILS_ENV=production bundle exec rake assets:precompile

COPY docker-entrypoint.sh /
ENTRYPOINT ["./docker-entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
