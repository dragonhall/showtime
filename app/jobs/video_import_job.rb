class VideoImportJob < ApplicationJob
  def perform(video_path, video_type: :film)
    unless File.exist?(video_path)
      failed(file: video_path, message: 'File not found')
      return
    end

    v = Video.find_or_create_by path: video_path

    movie = FFMPEG::Movie.new video_path

    if movie.valid?
      v.metadata ||= {}
      v.metadata[:length] = movie.duration.ceil
      v.metadata[:bitrate] = movie.video_bitrate > 0 ? movie.video_bitrate : 30_000
      v.metadata[:width] = movie.width
      v.metadata[:height] = movie.height
      v.metadata[:frame_rate] = (movie.frame_rate.to_f * 100).to_i / 100.0 # 2 decimals enough

      v.pegi_rating ||= :pegi_12
    end

    fv = FusionVideo.from_filepath(video_path)

    if fv && !fv.title.blank? then
      v.metadata[:title] = fv.title
    elsif !movie.format_tags[:title].blank?
      v.metadata[:title] = movie.format_tags[:title]
    else
      # fallback title creation mechanism
      v.metadata[:title] = File.basename(video_path).sub(/\.[a-z0-9]+$/, '')
                               .split(/[\s_]/).find_all do |e|
        !e.match(/(dummet|izzy|brolly|x264|\[(dragonhall|dh)\+\])/i)
      end.join(' ').gsub(/\[.+?\]/, '').strip
    end

    v.metadata[:title] = v.metadata[:title][0..18]

    v.video_type ||= video_type

    if v.valid?
      v.save
      completed
    else
      failed(error: "Cannot save #{video_path} with message #{v.errors.full_messages.to_sentence}")
    end
  end
end
