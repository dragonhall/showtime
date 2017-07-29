class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :check_blocked_ips

  before_action :authenticate_admin!
  before_action :set_correct_format, if: proc { request.xhr? }


  include Consul::Controller

  current_power do
    Power.new(current_admin || Admin.new(name: 'Jelentkezz be!'))
  end

  protected

  def set_correct_format
    if request.format == Mime::ALL
      request.format = params[:format] || :html
    end
  end

  def check_blocked_ips
    if BlockedIp.where(address: request.remote_ip).any?
      render status: :forbidden
    end
  end

end
