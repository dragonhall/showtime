# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include ResqueStatusAdapter
  include Rails.application.routes.url_helpers

  def default_url_options
    # if !Rails.application.config.action_mailer.default_url_options.empty?
    #   Rails.application.config.action_mailer.default_url_options
    if Rails.env.development?
      {host: 'showtime.lvh.me', port: 3000}
    else
      {host: 'showtime.dragonhall.hu', port: 80}
    end
  end
end
