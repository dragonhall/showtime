# frozen_string_literal: true

class VideoPreviewJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    @video = Video.find video_id

    FileUtils.mkdir_p(File.dirname(screenshot_path))

    movie = FFMPEG::Movie.new(@video.path)

    seek_time = if movie.duration > 300 then
                  300 + rand(movie.duration - 300 - 1)
                elsif movie.duration > 50 then
                  30 + rand(movie.duration - 30 - 1)
                else
                  1 + rand(movie.duration - 2)
                end

    movie.screenshot Rails.root.join('public', screenshot_path).to_s,
                     seek_time: seek_time,
                     resolution: '720x404',
                     custom:
                         %w(-vf [in]scale=720:404:force_original_aspect_ratio=decrease,pad=720:404:(ow-iw)/2:(oh-ih)/2)
    @video.update_attribute :screenshot_path, screenshot_path
    completed
  end

  def screenshot_path
    # Rails.root.join('public', 'screenshots', "video_#{@video.id}.png").to_s
    File.join('screenshots', "video_#{@video.id}.png")
  end
end
