# frozen_string_literal: true

class TvController < ApplicationController
  layout 'tv'

  skip_before_action :authenticate_admin!

  def index
    @channel = Channel.where(domain: request.host).first
    @playlist = if @channel.playlists.active.any?
                  @channel.playlists.active.first
                elsif @channel.playlists.at_today.any?
                  @channel.playlists.at_today.first
                elsif @channel.playlists.at_week.any?
                  @channel.playlists.at_week.first
                else
                  @channel.upcoming.first
                end

    respond_to do |format|
      format.html
      format.json do
        if @playlist.active?
          render json: {src: "http://#{@channel.domain}/live/#{@channel.stream_path}.m3u8"}
        else
          render status: :forbidden, json: {}
        end
      end
    end
  end
end
