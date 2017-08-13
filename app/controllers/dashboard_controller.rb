# frozen_string_literal: true

class DashboardController < ApplicationController
  respond_to :html, :json

  def index
    @clients = client_info.clients.find_all { |c| c.address != '127.0.0.1' }[0..9]
    @channels = current_power.channels
    @wip_playlists = Playlist.wip.where('playlists.channel_id IN(?)',
                                        current_power.channels.map(&:id))
    @upcoming_playlists = Playlist.upcoming
  end

  private

  def client_info
    @client_info ||= ClientInfo::Service.new
  end
end
