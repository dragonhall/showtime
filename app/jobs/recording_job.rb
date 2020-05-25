require 'fileutils'
require 'securerandom'

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

    render_video
  end

  private

  def recording_path
    Rails.root.join('tmp', 'recordings', job_id).to_s
  end

  def render_video
    movie = FFMPEG::Movie.new(@recording.video.path)
    ratio = movie.width.to_f / movie.height.to_f

    target_width = 720
    target_height = 404

    wspacing = ratio < 1.5 ? 22 + 91 : 22

    channel_logo = @recording.channel.logo.path if @recording.channel.logo?
    logo_path, logo_params = build_logo(channel_logo, target_width, target_height, wspacing)

    pegi_path, pegi_params = build_pegi(@recording.video.pegi_rating.sub(/^pegi_/, '').to_i, target_width, target_height, wspacing)

    filter_params = ''

    filter_params += "[in]scale=#{target_width}:#{target_height}:force_original_aspect_ratio=decrease,pad=#{target_width}:#{target_height}:(ow-iw)/2:(oh-ih)/2[scaled];"

    filter_params += "movie=#{logo_path}[logo];movie=#{pegi_path}[pegi];[scaled][logo]#{logo_params}[tmp];[tmp][pegi]#{pegi_params}"

    # bitrate = movie.video_bitrate > 3_000_000 ? 3_000_000 : movie.video_bitrate
    bitrate = 2_000_000
    bitrate = (bitrate / 1000.0).ceil


    transcoding_params = {}
    transcoding_params[:video_bitrate] = bitrate 
    transcoding_params[:x264_preset] = 'slow'

    transcoding_params[:custom] = %W[-qmin 4 -qmax 10 -subq 9 -r 23.976  -bsf:v h264_mp4toannexb -f mpegts]

    if @recording.video.metadata[:deinterlace] != '0'
      transcoding_params[:custom].unshift '-deinterlace '
    end

    transcoding_params.merge!(
      resolution: '720x404',
      video_codec: 'libx264',
      audio_codec: 'aac',
    )

    transcoding_params[:custom] += ['-vf', filter_params] unless filter_params.blank?

    # other_params = { validate: false }

    # public/recordings

    logger.debug 'transcoding will be started with following options: ' \
                 "#{transcoding_params}"

    at(0, 2, "Transcoding #{@recording.video.title} to MPEG")

    tmp_path = Rails.root.join(
        'tmp',
        'recordings',
        job_id,
        File.basename(@recording.video.path).sub(/\.\w+$/, '.ts')
    )

    target_path = Rails.root.join(
        'public',
        'recordings',
        @recording.id.to_s,
        "#{SecureRandom.urlsafe_base64(11)}.mp4"
    )

    FileUtils.mkdir_p(Rails.root.join('public', 'recordings', @recording.id.to_s))
    movie.transcode(tmp_path.to_s,
                    transcoding_params)

    at(1, 2, 'Adding intros to file and creating downloadable file')

    ret = system("#{Rails.root}/script/concat", job_id, tmp_path.to_s, target_path.to_s, @recording.video.pegi_rating)
    if ret
      @recording.update_attribute :path, target_path.to_s.sub(Rails.public_dir.to_s, '').sub(/^\//, '')
      completed "Video #{File.basename(target_path)} rendered successfully"
    else
      failed 'Final FFMPEG returned with non-zero status code'
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

    image.write "#{recording_path}/pegi.png"

    param = "overlay=#{wspacing}:#{h - target_height - 22}"

    [
      "#{recording_path}/pegi.png",
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

    image.write "#{recording_path}/logo.png"

    param = "overlay=#{w - target_width - wspacing}:22"

    [
      "#{recording_path}/logo.png",
      param
    ]
  end
end
