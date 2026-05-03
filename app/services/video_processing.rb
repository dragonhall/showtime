# frozen_string_literal: true

module VideoProcessing
  module_function

  # Renders a video to MPEGTS format with PEGI rating and channel logo overlay
  # @param video [Video] The video object to process
  # @param channel [Channel] The channel associated with the video
  # @param work_dir [Pathname] The working directory for temporary files
  # @param job_id [String] The unique identifier for the job
  # @param logger [Logger] The logger instance for logging progress and errors
  # @param at_callback [Proc] The progress callback for updating job status
  # @return [Hash] The result of the video processing, including temporary path
  def render_video(video:, channel:, work_dir:, job_id:, logger:, at_callback:)
    raise "Source video not found at #{video.path}" unless video.exists?

    movie = video.to_movie

    ratio = movie.width.to_f / movie.height
    wspacing = ratio < 1.5 ? 22 + 91 : 22

    target_width = 720
    target_height = 404

    logo_path = logo_params = nil
    if channel&.logo?
      channel_logo = Pathname.new(channel.logo.path.to_s)
      logo_path, logo_params = build_logo(work_dir, channel_logo, target_width, target_height, wspacing, logger: logger)
    end

    pegi_path, pegi_params = build_pegi(
      work_dir,
      video.pegi_rating.sub(/^pegi_/, '').to_i,
      target_width,
      target_height,
      wspacing,
      logger: logger
    )

    filter_params = '[in]'

    # # If we need deinterlace on the video, we add some extra filters before
    # if video.metadata[:deinterlace]
    #   filter_params += 'bwdif=mode=send_field:parity=auto:deint=all,'
    # end

    filter_params += "scale=#{target_width}:#{target_height}:force_original_aspect_ratio=decrease," \
                     "pad=#{target_width}:#{target_height}:(ow-iw)/2:(oh-ih)/2[scaled];"

    # Add the channel logo and PEGI to the video if needed
    #
    # @AI: The logic here is:
    #  - we need channel logo and PEGI if the video is a film (and the film falls to the logo-required PEGI rating)
    #  - we need only PEGI logo for trailes (no channel logo)
    #  - no channel logo or PEGI needed for any other video types (trailer, intro, rollover, etc)
    #    as they either have one or contain other brandings inside.
    #
    # This logic cannot be simplified as it leads to incorrect calculations and logo placements
    # rubocop:disable Style/EmptyElse
    if channel&.logo?
      case video.video_type
      when 'film'
        if %w[pegi_12 pegi_16 pegi_18].include?(video.pegi_rating) && pegi_path then
          if video.logo?
            filter_params += "movie=#{logo_path}[logo];movie=#{pegi_path}[pegi];[scaled][logo]#{logo_params}[tmp];"
            filter_params += "[tmp][pegi]#{pegi_params}"
          else
            filter_params += "movie=#{pegi_path}[pegi];[scaled][pegi]#{pegi_params}"
          end
        elsif video.logo? && logo_path
          filter_params += "movie=#{logo_path}[logo];[scaled][logo]#{logo_params}"
        end
      when 'trailer'
        if %w[pegi_12 pegi_16 pegi_18].include?(video.pegi_rating) && pegi_path then
          filter_params += "movie=#{pegi_path}[pegi];[scaled][pegi]#{pegi_params}"
        end
      else
        # nothing to do
      end
    end
    # rubocop:enable Style/EmptyElse

    filter_params = filter_params.sub(/\[scaled\];\Z/, '')

    bitrate = 1_000
    bitrate = (bitrate / 1000.0).ceil

    transcoding_params = {
      custom: []
    }

    # cut at the exact length of the video (sometimes ffmpeg runs over the end)
    transcoding_params[:custom] += %W[-t #{video.length}] if video.video_type == 'film'

    # Filters...
    transcoding_params[:custom] += ['-vf', filter_params] unless filter_params.blank?

    # ...and other quality settings and output format
    transcoding_params[:custom] += %w[-qmin 4 -qmax 10 -subq 9 -r 23.976 -bsf:v h264_mp4toannexb]

    # Ensure deinterlace if needed and it is the very first parameter
    # (otherwise the output does not match the expected quality)
    if video.metadata[:deinterlace] then
      transcoding_params[:custom].unshift('-deinterlace')
    end

    transcoding_params.merge!(
      resolution: "#{target_width}x#{target_height}",
      x264_preset: 'slow',
      video_bitrate: bitrate,
      video_codec: 'libx264',
      audio_codec: 'aac',
      audio_bitrate: '192k',
      audio_sample_rate: 48_000
    )

    logger.debug "Transcoding will be started with following options: #{transcoding_params}"

    at_callback.call(0, 2, "Transcoding #{video.title} to MPEGTS")

    tmp_path = work_dir.join("#{video.id}.ts")

    movie.transcode(tmp_path.to_s, transcoding_params)

    { tmp_path: tmp_path.to_s, pegi_rating: video.pegi_rating }
  end

  # rubocop:disable Metrics/ParameterLists, Naming/MethodParameterName
  def build_pegi(work_dir, rating, w, h, wspacing, logger: Rails.logger)
    rating_image = Rails.root.join("public/pegi_rating/#{rating}.png")
    return [nil, nil] unless rating_image.exist?

    logger.debug 'Building PEGI'

    image = MiniMagick::Image.open(rating_image.to_s)
    ratio = image.width.to_f / image.height
    target_width = w * 0.05
    target_height = target_width / ratio

    image.resize "#{target_width.ceil}x#{target_height.ceil}"
    image.format 'png'

    out_path = "#{Pathname.new(work_dir)}pegi.png"
    image.write out_path.to_s

    param = "overlay=#{wspacing}:#{h - target_height - 22}"
    [out_path.to_s, param]
  end
  # rubocop:enable Metrics/ParameterLists, Naming/MethodParameterName

  # rubocop:disable Metrics/ParameterLists, Naming/MethodParameterName
  def build_logo(work_dir, logo, w, _h, wspacing, logger: Rails.logger)
    logger.debug 'Building LOGO'

    image = MiniMagick::Image.open(logo)

    ratio = image.width.to_f / image.height
    target_width = w * 0.16
    target_height = target_width / ratio

    image.resize "#{target_width.ceil}x#{target_height.ceil}"
    image.format 'png'

    out_path = "#{Pathname.new(work_dir)}logo.png"
    image.write out_path.to_s

    param = "overlay=#{w - target_width - wspacing}:22"
    [out_path.to_s, param]
  end
  # rubocop:enable Metrics/ParameterLists, Naming/MethodParameterName
end
