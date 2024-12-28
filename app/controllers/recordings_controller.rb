# frozen_string_literal: true

class RecordingsController < ApplicationController
  layout 'tv'

  skip_before_action :authenticate_admin!

  def index
    @series = Video.series
    @recordings = if params[:series].blank?
                    Recording.available
                  else
                    Recording.available.joins(:video).where('videos.recordable' => true)
                  end
  end

  def show
    @recording = Recording.find(params[:id])

    send_file @recording.path, type: :mp4, disposition: :inline
  end
end
