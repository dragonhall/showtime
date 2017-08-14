class TvController < ApplicationController
  layout 'tv'

  skip_before_action :authenticate_admin!


  def index
    @channel = Channel.where(domain: request.host).first
    @playlist = @channel.playlists.at_today.any? ? @channel.playlists.at_today.first : nil

    respond_to do |format|
      format.html
      format.json do
        if @playlist
          render json: {src: "rtmp://tv.dragonhall.hu:1935/live/#{@channel.stream_path}" }
        else
          render status: :forbidden
        end
      end
    end
  end
end

