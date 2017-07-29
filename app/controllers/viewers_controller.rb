class ViewersController < ApplicationController

  def index
    # @type [Array<ClientInfo::Client>]
    @clients = client_service.clients
  end

  def show
    client_id = params[:id]
    # @type [Array<ClientInfo::Client>]
    clients = client_service.clients
    @client = clients.find { |c| c.client_id == client_id }
  end

  def kill

  end

  def block

  end


  protected

  def client_service
    @client_service ||= ClientInfo::Service.new
  end
end