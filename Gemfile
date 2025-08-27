# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rails", "~> 7.2.0"
gem "octokit", ">= 4.0"
gem "importmap-rails"
gem "stimulus-rails"

group :development, :test do
  gem "puma"
  gem "sqlite3"
  gem "pg"
  gem "rake"
  gem "dotenv"
  gem "minitest"
  gem "standard"
  gem "appraisal"
  gem "better_errors"
  gem "binding_of_caller"
  gem "sprockets-rails"

  gem "solid_queue"
  gem "mission_control-jobs"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
