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

gem 'mysql2' # , '>= 0.3.18', '< 0.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '~> 5.2.4', '>= 5.2.4.3'
gem 'rails', '~> 6.0'

gem 'puma'

group :assets do
  gem 'coffee-rails', '~> 4.2', '>= 4.2.2'
  gem 'jbuilder', '~> 2.5'
  gem 'jqtools-rails'
  gem 'jquery-easing-rails', '>= 0.0.2'
  gem 'jquery-rails', '>= 4.4.0'
  gem 'jquery-ui-rails', '>= 6.0.1'
  gem 'sassc-rails', '~> 2.1.2'
  gem 'uglifier', '>= 1.3.0'

  gem 'blueprint-rails', github: 'hron84/blueprint-rails',
                         branch: 'hron84/rails-6-upgrade'
  gem 'facebox-rails', github: 'hron84/facebox-rails',
                       branch: 'hron84/feature-rails6'
end

# group :development, :test do
#  gem 'byebug'
# end

group :development do
  #   # Access an IRB console on exception pages or by using
  #   # <%= console %> anywhere in the code.
  #   # gem 'web-console', '>= 3.3.0'
  #   gem 'better_errors'
  #   gem 'binding_of_caller'
  #
  gem 'capistrano3-monit', require: false
  gem 'capistrano3-puma', '6.0.0.beta.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-foreman', require: false
  gem 'capistrano-linked-files', require: false
  gem 'capistrano-rails', require: false
  gem 'rvm1-capistrano3', require: false
  #
  #   gem 'listen', '>= 3.0.5', '< 3.2'
  #   gem 'meta_request', '>= 0.7.2'
  #
  #   # Spring speeds up development by keeping your application
  #   # running in the background. Read more: https://github.com/rails/spring
  #   gem 'spring'
  #   gem 'spring-commands-rspec'
  #   gem 'spring-watcher-listen', '~> 2.0.0'
  #
  gem 'foreman'
  #   # Guard
  guard rails: :latest,
        spring: :latest,
        rspec: :latest,
        bundler: :latest,
        rake: :latest
  # resque: :latest
  #
  gem 'guard-resque', github: 'jacquescrocker/guard-resque', branch: :master
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '>= 6.1.0'
  gem 'fuubar'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec', require: false
  gem 'simplecov'

  gem 'faker'
end

group :application do
  gem 'active_scheduler'
  gem 'pry-rails'

  gem 'carrierwave', '>= 2.1.1'
  gem 'consul', '>= 1.0.3'
  gem 'devise', '>= 4.7.2' # , github: 'plataformatec/devise'
  gem 'haml-rails', '>= 2.0.1'
  gem 'inherited_resources', '>= 1.11.0'
  gem 'kaminari', '>= 1.2.1'
  gem 'kaminari-i18n', '>= 0.5.0'

  gem 'mini_magick'

  gem 'rack-dev-mark'

  gem 'rails-i18n', '>= 5.1.3'

  gem 'redis', '< 4.3'
  gem 'resque'
  gem 'resque-scheduler'
  gem 'resque-scheduler-web', '>= 1.1.0'
  gem 'resque-status'
  gem 'resque-status-web', '>= 0.1.0'
  gem 'resque-web', github: 'EdCordata/resque-web',
                    branch: 'fix/file-to-import-not-found-or-unreadable-font-awesome-sprockets', require: 'resque_web'

  gem 'rollbar'
  gem 'simple_form', '>= 5.0.2'

  gem 'streamio-ffmpeg', github: 'streamio/streamio-ffmpeg', branch: :master

  gem 'twitter-bootstrap-rails', '>= 3.2.2'

  gem 'imgkit'
  gem 'wkhtmltoimage-binary' if RUBY_PLATFORM.match?(/linux|darwin/)

  gem 'geoip'

  gem 'google-analytics-rails'
end
