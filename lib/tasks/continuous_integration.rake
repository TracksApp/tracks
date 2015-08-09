namespace :ci do
  desc 'Continuous integration tests, without features'
  task :lite do
    ENV['RAILS_ENV']  ||= "test"

    puts 'Running "lite" test suite'

    [:environment, 'db:create', :test].each do |t|
      Rake::Task[t].invoke
    end
  end

  desc 'Continuous integration tests, including features'
  task :full do |t|
    puts 'Running full test suite'

    # test coverage from codeclimate
    require "codeclimate-test-reporter"
    CodeClimate::TestReporter.start

    # local test coverage
    require 'simplecov'
    SimpleCov.start 'rails'

    ['ci:lite', 'cucumber'].each do |t|
      Rake::Task[t].invoke
    end
  end
end

desc 'Alias for ci:full'
task :ci => 'ci:full'
