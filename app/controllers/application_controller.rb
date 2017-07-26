class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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

end
