task :ci do |t|
  ENV['RAILS_ENV']  ||= "test"

  # test coverage from codeclimate
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start

  # local test coverage
  require 'simplecov'
  SimpleCov.start 'rails'

  [:environment, 'db:create', 'test:all', 'cucumber'].each do |t|
    Rake::Task[t].invoke
  end
end
