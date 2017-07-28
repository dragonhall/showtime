require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require "action_cable/engine"
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups, :assets, :application)

module Showtime
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.time_zone = 'Budapest'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    ## Don't generate system test files.
    # config.generators.system_tests = nil

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app/inputs')
    config.autoload_paths << Rails.root.join('app/serializers')

    config.log_formatter = ::Logger::Formatter.new

    if config.respond_to? :rack_dev_mark
      config.rack_dev_mark.enable = true
      config.rack_dev_mark.env =
        "#{Rails.env} (#{%x(git rev-parse HEAD).strip[0...6]})"
    end


    config.active_job.queue_adapter = :resque

    # config.active_job.default_url_options = { host: 'localhost' }

    config.generators do |generators|
      unless Rails.env.production? then
        generators.test_framework :rspec,
                                  view_specs: false,
                                  helper_specs: false,
                                  routing_specs: false,
                                  request_specs: false,
                                  fixtures: true
        generators.integration_tool :rspec
        generators.fixture_replacement :factory_girl, dir: 'spec/factories'
      end
      generators.stylesheets :scss
      generators.template_engine :haml
    end
  end
end

Dir.glob(Rails.root.join('app', 'renderers', '*.rb').to_s).each { |f| require f }