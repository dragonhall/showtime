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
          render json: {src: "rtmp://tv.dragonhall.hu:1935/live/#{@channel.stream_path}"}
        else
          render status: :forbidden, json: {}
        end
      end
    end
  end
end

