# frozen_string_literal: true

require 'fileutils'
require 'securerandom'

require 'video_processing'

class RecordingJob < ApplicationJob
  queue_as :recording

  # @type [Recording]
  attr_reader :recording

  before_perform do
    FileUtils.mkdir_p Rails.root.join('tmp', 'recordings', job_id)
  end

  # after_perform do
  #   FileUtils.rmtree Rails.root.join('tmp', 'recordings', job_id)
  # end

  def perform(recording_id)
    FFMPEG.logger = logger

    @recording = Recording.find recording_id
    work_dir = Rails.root.join('tmp', 'recordings', job_id)

    # Process video, potentially with channel logo overlay
    render_result = VideoProcessing.render_video(
      video: @recording.video,
      channel: @recording.channel,
      work_dir: work_dir,
      job_id: job_id,
      logger: logger,
      at_callback: method(:at)
    )

    at(1, 2, 'Adding intros to file and creating downloadable file')

    target_path = Rails.root.join(
      'public',
      'recordings',
      @recording.id.to_s,
      "#{SecureRandom.urlsafe_base64(11)}.mp4"
    )

    FileUtils.mkdir_p(Rails.root.join('public', 'recordings', @recording.id.to_s))

    # @todo Should concat take a `pegi_rating` param still? The work is done in #render_video now?
    ret = system("#{Rails.root}/script/concat", job_id, render_result[:tmp_path], target_path.to_s,
render_result[:pegi_rating])
    if ret
      @recording.update_attribute :path, target_path.to_s.sub(Rails.public_dir.to_s, '').sub(%r{^/}, '')
      completed "Video #{File.basename(target_path)} rendered successfully"
    else
      failed 'Final FFMPEG returned with non-zero status code'
    end
  ensure
    # Clean up after ourselves, even if the job failed
    FileUtils.rmtree work_dir if Dir.exist?(work_dir)
  end
end
