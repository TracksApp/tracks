FROM ruby:2.4

WORKDIR /app

RUN touch /etc/app-env

COPY Gemfile* /app/
RUN gem install bundler
RUN bundle install

RUN mkdir /app/log

COPY . /app/

EXPOSE 3000
