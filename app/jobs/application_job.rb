class ApplicationJob < ActiveJob::Base
  include ResqueStatusAdapter


  protected

  def url_helpers
    Rails.application.routes.url_helpers
  end

end
