class PlaylistsController < InheritedResources::Base
  belongs_to :channel

  respond_to :json, :html

  skip_before_action :authenticate_admin!, only: :program

  layout false

  def create
    create! { root_url }

  end

  def update
    update!  { root_url }

  end

  def destroy
    destroy! { root_url }
  end

  def play

    @playlist ||= Playlist.find(params[:id]) rescue nil
    @channel = Channel.where(domain: '#technical').first

    if @playlist
      @playlist.stream_to_technical
      render 'tv/index', layout: false
    else
      redirect_to root_url
    end

  end

  def program
    @playlist ||= Playlist.find(params[:id]) rescue nil

    if @playlist # && @playlist.finalized?
      redirect_to "/programs/channel_#{@playlist.channel.id}/#{@playlist.id}/#{@playlist.start_time.strftime('%F')}.png", status: :found
    else
      render 'public/404.html', status: :not_found
    end
  end

  def current_program
    respond_to do |format|
      format.html do
        if Playlist.current.any?

          @playlist = Playlist.current.first
          redirect_to "/programs/channel_#{@playlist.channel.id}/#{@playlist.id}/#{@playlist.start_time.strftime('%F')}.png", status: :found
        else
          render file: 'public/404.html', status: :not_found
        end
      end
    end
  end

  #
  # def reorder
  #   tracks = params[:track]
  #   tracks.each_with_index do |id, idx|
  #     track = @playlist.tracks.find id
  #     track.update_attribute :position, idx + 1
  #   end
  #
  #   head :ok
  # end

  private

  def playlist_params
    params.require(:playlist).permit(:channel_id, :start_time, :title, :finalized)
  end
end

