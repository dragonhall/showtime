class TracksController < InheritedResources::Base
  belongs_to :playlist

  respond_to :json, :html

  layout 'playlist', only: :index

  before_action :set_title

  skip_before_action :authenticate_admin!, only: :index

  def create
    create! do |success, _failure|
      success.json do
        render status: :created, json: {
          track: {
            id: @track.id,
            position: @track.position,
            title: @track.title,
            start_time: @track.start_time.strftime('%H:%M'),
            length: Time.at(@track.length).utc.strftime('%H:%M')
          }
        }
      end
    end
  end

  def reorder
    tracks = params[:tracks].map { |id| Track.find(id) }

    tracks.each_with_index do |track, idx|
      track.update_attribute :position, idx + 1
    end

    respond_to do |format|
      format.json do
        render json: {
          tracks: tracks.map do |track|
                    {
                      id: "track_#{track.id}",
                      position: track.position,
                      start_time: track.start_time.strftime('%H:%M')
                    }
                  end
        }
      end
    end
  end

  private

  def set_title
    playlist = Playlist.find(params[:playlist_id])

    @title = if playlist.start_time == Time.zone.now.to_date
               'Mai'
             elsif playlist.start_time >= Time.zone.now.to_date.beginning_of_week &&
                   playlist.start_time <= Time.zone.now.to_date.end_of_week
               'Heti'
             elsif playlist.start_time >= 7.days.from_now.to_date.beginning_of_week &&
                   playlist.start_time <= 7.days.from_now.to_date.end_of_week
               'Jövő Heti'
             else
               'Következő'
             end

    @title += ' Műsor'
  end

  def track_params
    params.require(:track).permit(:playlist_id, :video_id)
  end
end
