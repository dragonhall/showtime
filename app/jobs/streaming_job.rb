# frozen_string_literal: true

require 'fileutils'
class StreamingJob
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
    # puts options.to_json; return

    playlist_id = options['playlist_id']

    FFMPEG.logger = logger

    # We hacking around for console-initiated "debug" runs, where we just pass the whole playlist...
    begin
      playlist = if playlist_id.is_a?(Playlist) then
                   playlist_id
                 else
                   Playlist.find(playlist_id)
                 end
      playlist_id = playlist.id
    rescue ActiveRecord::RecordNotFound => e
      failed "Cannot play Playlist##{playlist_id}: #{e.message}"
      return
    end

    failed "Cannot play Playlist##{playlist_id}: not finalized" unless playlist.finalized?
    failed "Cannot play Playlist##{playlist_id}: not streamable" unless playlist.streamable?

    FileUtils.mkdir_p Rails.root.join('tmp', 'streaming', job_id.to_s)

    # TODO: we should track the progress of the stream somehow on tracks too,
    # because we currently effectively disable the "current track" feature for Google Analytics

    playlist.channel.hd?

    playlist.update_attribute :playing, true
    stream_video playlist.stream_path, playlist.channel, playlist.duration
    playlist.update_attribute :playing, false

    # FileUtils.rm_rf Rails.root.join('tmp', 'streaming', job_id.to_s)
  end

  private

  # @return [ActiveSupport::Logger]
  def logger
    @logger ||= ::Logger.new(Rails.root.join('log', 'streaming.log'))
  end

  # @param [Video] video
  # @param [Channel] channel

  def stream_video(stream_path, channel, expected_duration, hd: false)
    movie = FFMPEG::Movie.new(stream_path)

    # ratio = movie.width / movie.height.to_f

    target_width = hd ? 1280 : 720

    # target_height = ratio < (16.0 / 9.0) ? 540 : 404
    target_height = hd ? 720 : 404

    filter_params = ''

    # Enforce output resolution and aspect ratio (this can be tricky when we stream HD content for SD channel)
    filter_params += "[in]scale=#{target_width}:#{target_height}:force_original_aspect_ratio=decrease,pad=#{target_width}:#{target_height}:(ow-iw)/2:(oh-ih)/2"

    bitrate = 1_000
    bitrate = (bitrate / 1000.0).ceil

    transcoding_params = {custom: %W[-t #{expected_duration}]}

    transcoding_params[:custom] += ['-vf', filter_params] unless filter_params.blank?
    transcoding_params[:custom] += %w[-qmin 4 -qmax 10 -subq 9 -r 23.976 -f flv]

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

    # We handle multiple domains for streaming, including streaming to external places
    # NOTE: for non-DragonHall targets, we have to set the actual path (minus the domain) as a stream path
    #       because StreamingJob cannot figure out the path logic for external targets
    rtmp_domain = channel.domain.blank? || channel.domain == '#technical' ? 'tv.dragonhall.hu' : channel.domain
    stream_path = (rtmp_domain.match?(/dragonhall\.hu$/) ? "live/#{channel.stream_path}" : channel.stream_path)

    movie.transcode("rtmp://#{rtmp_domain}:1935/#{stream_path}",
                    transcoding_params,
                    other_params)

    stop_time = Time.zone.now

    elapsed = (stop_time - start_time).ceil
    timediff = expected_duration - elapsed
    if timediff.positive?
      logger.fatal "Playing #{stream_path} ended too early. Expected end time: " +
                   (start_time + expected_duration).to_s
      sleep(timediff) # TODO:  replace it with looping monoscope/error video
    end
  end

  # @param [Integer] secs
  # @param [String]  image
  # @param [String]  music
  # @param [Channel] channel

  def loop(secs, image: nil, music: 'loop.mp3', channel: nil)
    target_width = 720
    target_height = 404
    vf = "[in]scale=#{target_width}:#{target_height}:force_original_aspect_ratio=decrease,pad=#{target_width}:#{target_height}:(ow-iw)/2:(oh-ih)/2[scaled];"
    cmd1 = %W[/usr/bin/ffmpeg -y -loglevel 0 -re -stream_loop -1 -i #{Rails.root.join('public', 'streaming', music)} -f
              mp3 -]
    cmd2 = %W[/usr/bin/ffmpeg -y -re -i pipe:0 -loop 1 -i #{image} -vf #{vf} -t #{secs} -f flv
              rtmp://tv.dragonhall.hu:1935/live/#{channel.stream_path}]

    # rubocop:disable Style/StringConcatenation
    pipecmd = cmd1.map { |e| "'#{e}'" }.join(' ') + ' | ' +
              cmd2.map { |e| "'#{e}'" }.join(' ')
    # rubocop:enable Style/StringConcatenation

    system(pipecmd)
  end

  def job_id
    @uuid
  end
end
