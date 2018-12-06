FROM ruby:2.3

WORKDIR /app

RUN touch /etc/app-env

COPY Gemfile* /app/
RUN bundle install

RUN mkdir /app/log

COPY . /app/

RUN cp /app/config/site.yml.tmpl /app/config/site.yml

EXPOSE 3000
