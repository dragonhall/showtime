# frozen_string_literal: true

class DashboardController < ApplicationController
  respond_to :html, :json

  def index
    @clients = []
    @channels = current_power.channels
    @wip_playlists = Playlist.wip.where('playlists.channel_id IN(?)',
                                        current_power.channels.map(&:id))
    @upcoming_playlists = Playlist.where('playlists.channel_id IN(?)',
                                         current_power.channels.map(&:id)).upcoming

  end

  private
end
