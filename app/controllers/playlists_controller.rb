class PlaylistsController < InheritedResources::Base
  belongs_to :channel

  respond_to :json, :html

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

