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
    client_service.kill_client params[:id]
  end

  def block
    BlockedIp.find_or_create_by address: params[:address]
  end


  protected

  def client_service
    @client_service ||= ClientInfo::Service.new
  end
end