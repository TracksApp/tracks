FROM ruby:2.3

WORKDIR /app

RUN touch /etc/app-env

COPY Gemfile* /app/
RUN bundle install

RUN mkdir /app/log

COPY . /app/

EXPOSE 3000
