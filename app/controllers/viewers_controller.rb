class ViewersController < ApplicationController

  def show
    client_id = params[:id]
    # @type [Array<ClientInfo::Client>]
    @clients = ClientInfo::Service.new.clients
    @clients.find { |c| c.client_id == client_id }
  end

  def kill

  end

  def block

  end
end