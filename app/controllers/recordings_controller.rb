class RecordingsController < ApplicationController
  layout 'tv'

  skip_before_action :authenticate_admin!

  def index
    @series = Video.series
    if params[:series].blank?
      @recordings = Recording.available
    else
      @recordings = Recording.available.joins(:video).where('videos.series' => params[:series])
    end
  end

  def show
    @recording = Recording.find(params[:id])

    send_file @recording.path, type: :mp4, disposition: :inline
  end
end
