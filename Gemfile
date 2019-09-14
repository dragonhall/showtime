# frozen_string_literal: true

source 'https://rubygems.org'

ENV['RUBY_DEP_GEM_SILENCE_WARNINGS'] = '1' if %x(hostname -s).strip == 'darkstar'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

git_source(:bitbucket) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://bitbucket.org/#{repo_name}.git"
end

def guard(plugins = {})
  gem 'guard'
  plugins.each_pair do |name, version|
    if version == :latest
      gem "guard-#{name}", require: false
    else
      gem "guard-#{name}", version, require: false
    end
  end
end

gem 'mysql2', '>= 0.3.18', '< 0.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'

gem 'puma', '3.8.2'

group :assets do
  gem 'blueprint-rails', github: 'hron84/blueprint-rails',
                         branch: 'hron84/rails-5-upgrade'
  gem 'coffee-rails', '~> 4.2'
  gem 'facebox-rails', github: 'hron84/facebox-rails',
                       branch: 'hron84/feature-rails5'
  gem 'jbuilder', '~> 2.5'
  gem 'jqtools-rails'
  gem 'jquery-easing-rails'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
  gem 'sassc-rails', '~> 2.1.0'
  gem 'uglifier', '>= 1.3.0'
end

group :development, :test do
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using
  # <%= console %> anywhere in the code.
  # gem 'web-console', '>= 3.3.0'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'capistrano-bundler', require: false
  gem 'capistrano-linked-files', require: false
  gem 'capistrano-rails', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-foreman', require: false

  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'meta_request'

  # Spring speeds up development by keeping your application
  # running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Guard
  guard rails: :latest,
        spring: :latest,
        rspec: :latest,
        bundler: :latest,
        rake: :latest
  # resque: :latest

  gem 'guard-resque', github: 'jacquescrocker/guard-resque', branch: :master
end

group :test do
  gem 'factory_bot_rails'
  gem 'fuubar'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec', require: false
  gem 'simplecov'
  gem 'database_cleaner'

  gem 'faker'
end

group :application do
  gem 'active_scheduler'
  gem 'pry-rails'

  gem 'foreman'

  gem 'carrierwave'
  gem 'consul'
  gem 'devise' # , github: 'plataformatec/devise'
  gem 'haml-rails'
  gem 'inherited_resources'
  gem 'kaminari'

  gem 'mini_magick'

  gem 'rack-dev-mark'

  gem 'rails-i18n'

  gem 'resque'
  gem 'resque-scheduler'
  gem 'resque-scheduler-web'
  gem 'resque-status'
  gem 'resque-status-web'
  gem 'resque-web', require: 'resque_web'

  gem 'rollbar'
  gem 'simple_form'

  gem 'streamio-ffmpeg', github: 'streamio/streamio-ffmpeg', branch: :master

  # gem 'blueprint-rails', path: '/home/hron/Projects/contrib/blueprint-rails'

  gem 'twitter-bootstrap-rails'

  gem 'imgkit'
  gem 'wkhtmltoimage-binary' if RUBY_PLATFORM.match?(/linux|darwin/)

  gem 'geoip'

  gem 'google-analytics-rails'
end
