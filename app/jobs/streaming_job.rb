# frozen_string_literal: true

require 'fileutils'
class StreamingJob # < ApplicationJob
  include Resque::Plugins::Status

  # queue_as :streaming
  @queue = 'streaming'

  # before_perform do
  #  FileUtils.mkdir_p Rails.root.join('tmp', 'streaming', job_id.to_s)
  # end

  # after_perform do
  #  FileUtils.rm_rf Rails.root.join('tmp', 'streaming', job_id.to_s)
  # end

  def perform
    playlist_id = options['playlist_id']

    FFMPEG.logger = logger

    begin
      playlist = if playlist_id.is_a?(Playlist) then
                   playlist_id
                 else
                   Playlist.find(playlist_id)
                 end
    rescue ActiveRecord::RecordNotFound => e
      failed "Cannot play Playlist##{playlist_id}: #{e.message}"
      return
    end

    failed "Cannot play Playlist#{playlist_id}: not finalized" unless playlist.finalized?

    total = playlist.tracks.count

    logger.debug "Playing #{total} tracks"

    FileUtils.mkdir_p Rails.root.join('tmp', 'streaming', job_id.to_s)

    playlist.tracks.each_with_index do |track, i|
      next if playlist.tracks.where(playing: true).any? && !track.playing?

      track.update_attribute :playing, true

      at(i + 1, total, "Playing #{track.title} on [#{playlist.channel.name}] until #{track.end_time}")

      logger.debug "Started playing #{track.title} on [#{playlist.channel.name}], " \
                   "planned start: #{track.start_time}, planned end: #{track.end_time}"

      if File.exist?(track.video.path)
        # Loading video
        stream_video track.video, channel: playlist.channel
      else
        logger.fatal "Playing movie failed: missing file: '#{track.video.path}'"
        failed "Playing movie failed: missing file: '#{track.video.path}'"
        sleep track.length # TODO: replace it with looping monoscope/error video
      end

      track.update_attribute :playing, false
    end

    FileUtils.rm_rf Rails.root.join('tmp', 'streaming', job_id.to_s)
  end

  private

  # @return [ActiveSupport::Logger]
  def logger
    @logger ||= ::Logger.new(Rails.root.join('log', 'streaming.log'))
  end

  # @param [Video] video
  # @param [Channel] channel

  def stream_video(video, channel: nil)
    movie = video.to_movie

    ratio = movie.width / movie.height.to_f

    target_width = 720

    # target_height = ratio < (16.0 / 9.0) ? 540 : 404
    target_height = 404

    # wspacing = ratio < (16.0 / 9.0) ? 22 + 91 : 22
    wspacing = ratio < 1.5 ? 22 + 91 : 22

    channel_logo = channel.logo.path if channel.logo?

    logo_path, logo_params = build_logo(channel_logo, target_width, target_height, wspacing) if channel.logo?

    pegi_path, pegi_params = build_pegi(video.pegi_rating.sub(/^pegi_/, '').to_i, target_width, target_height, wspacing)

    filter_params = ''

    filter_params += "[in]scale=#{target_width}:#{target_height}:force_original_aspect_ratio=decrease,pad=#{target_width}:#{target_height}:(ow-iw)/2:(oh-ih)/2[scaled];"

    if channel.logo?
      case video.video_type
      when 'film'
        if %w[pegi_12 pegi_16 pegi_18].include?(video.pegi_rating) && pegi_path then
          filter_params += "movie=#{logo_path}[logo];movie=#{pegi_path}[pegi];[scaled][logo]#{logo_params}[tmp];[tmp][pegi]#{pegi_params}"
        else
          filter_params += "movie=#{logo_path}[logo];[scaled][logo]#{logo_params}" if logo_path
        end
      when 'trailer'
        if %w[pegi_12 pegi_16 pegi_18].include?(video.pegi_rating) && pegi_path then
          filter_params += "movie=#{pegi_path}[pegi];[scaled][pegi]#{pegi_params}"
        end
      else
        # nothing to do
      end
    end

    filter_params.sub!(/\[scaled\];\Z/, '')

    bitrate = 1_000
    bitrate = (bitrate / 1000.0).ceil

    transcoding_params = {custom: %W[-t #{video.length}]}

    transcoding_params[:custom] += ['-vf', filter_params] unless filter_params.blank?
    transcoding_params[:custom] += %w[-qmin 4 -qmax 10 -subq 9 -r 23.976 -f flv]

    if !video.metadata[:deinterlace].blank? && video.metadata[:deinterlace] != '0'
      transcoding_params[:custom].unshift '-deinterlace'
    end

    transcoding_params.merge!(
      resolution: "#{target_width}x#{target_height}",
      # x264_preset: 'slow',
      video_bitrate: bitrate,
      video_codec: 'libx264',
      audio_codec: 'aac'
    )

    other_params = { input_options: ['-re'], validate: false }

    logger.debug 'streaming will be started with following options: ' \
                 "#{transcoding_params} and #{other_params}"

    start_time = Time.zone.now
    # movie.transcode("rtmp://127.0.0.1:1935/dragonhall/#{channel.stream_path}")

    movie.transcode("rtmp://dragonhall.hu:1935/live/#{channel.stream_path}",
                    transcoding_params,
                    other_params)

    stop_time = Time.zone.now

    elapsed = (stop_time - start_time).ceil
    timediff = video.metadata[:length] - elapsed
    if timediff > 0
      logger.fatal "Playing #{video.path} ended too early. Expected end time: " +
                   (start_time + video.metadata[:length]).to_s
      sleep(timediff) # TODO:  replace it with looping monoscope/error video
    end
  end

  def build_pegi(rating, w, h, wspacing)
    rating_image = Rails.root.join("public/pegi_rating/#{rating}.png").to_s

    return [nil, nil] unless File.exist?(rating_image)

    logger.debug 'Building PEGI'

    image = MiniMagick::Image.open rating_image

    ratio = image.width.to_f / image.height.to_f
    target_width = w * 0.05
    target_height = target_width / ratio

    image.resize "#{target_width.ceil}x#{target_height.ceil}"
    image.format 'png'
    image.write Rails.root.join('tmp', 'streaming', job_id.to_s, 'pegi.png')

    param = "overlay=#{wspacing}:#{h - target_height - 22}"

    [
      Rails.root.join('tmp', 'streaming', job_id.to_s, 'pegi.png'),
      param
    ]
  end

  def build_logo(logo, w, _h, wspacing)
    logger.debug 'Building LOGO'

    image = MiniMagick::Image.open logo

    # Calculate new image sizes
    ratio = image.width.to_f / image.height.to_f
    target_width = w * 0.16
    target_height = target_width / ratio

    image.resize "#{target_width.ceil}x#{target_height.ceil}"
    image.format 'png'
    # image.write Rails.root.join('tmp', job_id.to_s + '_logo.png')
    image.write Rails.root.join('tmp', 'streaming', job_id.to_s, 'logo.png')

    param = "overlay=#{w - target_width - wspacing}:22"

    [
      Rails.root.join('tmp', 'streaming', job_id.to_s, 'logo.png'),
      param
    ]
  end

  # @param [Integer] secs
  # @param [String]  image
  # @param [String]  music
  # @param [Channel] channel

  def loop(secs, image: nil, music: 'loop.mp3', channel: nil)
    target_width = 720
    target_height = 404
    vf = "[in]scale=#{target_width}:#{target_height}:force_original_aspect_ratio=decrease,pad=#{target_width}:#{target_height}:(ow-iw)/2:(oh-ih)/2[scaled];"
    cmd1 = %W[/usr/bin/ffmpeg -y -loglevel 0 -re -stream_loop -1 -i #{Rails.root.join('public', 'streaming', music)} -f mp3 -]
    cmd2 = %W[/usr/bin/ffmpeg -y -re -i pipe:0 -loop 1 -i #{image} -vf #{vf} -t #{secs} -f flv rtmp://tv.dragonhall.hu:1935/live/#{channel.stream_path}]

    pipecmd = cmd1.map { |e| "'#{e}'" }.join(' ') + ' | ' +
              cmd2.map { |e| "'#{e}'" }.join(' ')

    system(pipecmd)
  end

  def job_id
    @uuid
  end
end
