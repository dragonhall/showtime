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
    tracks = params[:tracks].map { |id| Track.find(id) }

    if !tracks.first.playlist.finalized?

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
    else
      render json: {error: "Tracks cannot moved when they're finalized"},
             status: :forbidden
    end
  end

  def wrap
    _playlist = Playlist.find(params[:playlist_id])
    _playlist.wrap_films!
    redirect_to root_path
  end

  private

  def set_title
    playlist = Playlist.find(params[:playlist_id])

    @title = if playlist.start_time.to_date == Time.zone.now.to_date then
               'Mai'
             elsif playlist.start_time.to_date == (Time.zone.now - 1.day).to_date then
               'Tegnapi'
             elsif playlist.start_time.to_date == (Time.zone.now + 1.day).to_date then
               'Holnapi'
             elsif playlist.start_time >= Time.zone.now.to_date.beginning_of_week &&
                   playlist.start_time <= Time.zone.now.to_date.end_of_week then
               # 'Heti'
               I18n.l(playlist.start_time, format: '%Ai').titleize
             elsif playlist.start_time >= 7.days.from_now.to_date.beginning_of_week &&
                   playlist.start_time <= 7.days.from_now.to_date.end_of_week then
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
