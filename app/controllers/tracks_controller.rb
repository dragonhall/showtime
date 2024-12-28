# frozen_string_literal: true

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
            start_time: @track.start_time.strftime('%H:%M:%S'),
            length: Time.at(@track.length).utc.strftime('%H:%M:%S'),
            video_type: @track.video.video_type
          }
        }
      end
    end
  end

  def reorder
    # tracks = params[:tracks].map { |id| Track.find(id) }
    tracks = Track.where(id: params[:tracks]).includes(:playlist)

    if tracks.first.playlist.finalized?
      render json: {error: "Tracks cannot moved when they're finalized"},
             status: :forbidden
    else

      tracks.each_with_index do |track, idx|
        track.update_attribute :position, idx + 1 if track.position != idx + 1
        track.reload
      end

      respond_to do |format|
        format.json do
          render json: {
            tracks: tracks.map do |track|
                      {
                        id: "track_#{track.id}",
                        position: track.position,
                        start_time: track.start_time.strftime('%H:%M:%S')
                      }
                    end
          }
        end
      end
    end
  end

  def wrap
    a_playlist = Playlist.find(params[:playlist_id])
    a_playlist.wrap_films!
    redirect_to root_path
  end

  private

  def set_title
    playlist = Playlist.find(params[:playlist_id])

    @title = playlist.human_title
  end

  def track_params
    params.require(:track).permit(:playlist_id, :video_id)
  end
end
