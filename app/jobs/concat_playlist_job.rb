# frozen_string_literal: true

require 'English'
require 'shellwords'
class ConcatPlaylistJob < ApplicationJob
  queue_as :recording

  before_perform do
    FileUtils.mkdir_p Rails.root.join('tmp', 'streaming', job_id)
  end

  after_perform do
    # FileUtils.rmtree Rails.root.join('tmp', 'streaming', job_id)
  end

  attr_reader :videos

  def perform(options = {})
    opts = options.with_indifferent_access
    begin
      @playlist = Playlist.find(opts[:playlist_id])
    rescue Exception => e
      message = "Playlist not found: #{e.message}"
      Rails.logger.error
      failed message
    end

    return if @playlist.blank?

    @videos = @playlist.tracks.collect(&:video)

    concat_files = concat_playlist_videos
    concat_videos_to_mp4 concat_files unless concat_files.blank?
  end

  private

  def concat_playlist_videos
    concat_entries = []
    work_dir = Rails.root.join('tmp', 'streaming', job_id)

    # Track the progress for videos being processed
    total_videos = @videos.size
    processed_count = 0

    @videos.each do |video|
      processed_count += 1

      # Generate a consistent, unique name for the processed video file
      # This allows us to identify already processed videos
      target_filename = "#{video.id}.ts"
      target_path = work_dir.join(target_filename)

      # Skip processing if the file already exists
      if target_path.exist? then
        logger.info "Skipping already processed video #{processed_count}/#{total_videos}: #{video.title}"
      else
        logger.info "Processing video #{processed_count}/#{total_videos}: #{video.title}"

        # Define a simple progress callback for the video processing
        at_callback = lambda do |current, total, message|
          at((processed_count - 1 + (current.to_f / total)) / total_videos, total_videos, message)
        end

        # Process the video
        begin
          result = VideoProcessing.render_video(
            video: video,
            channel: @playlist.channel, # Use the playlist's channel for logo
            work_dir: work_dir,
            job_id: job_id,
            logger: logger,
            at_callback: at_callback
          )

          # Rename the generated file to our target path for consistency
          FileUtils.mv(result[:tmp_path], target_path.to_s) unless result[:tmp_path] == target_path.to_s
        rescue StandardError => e
          logger.error "Failed to process video #{video.id} (#{video.title}): #{e.message}"
          # Continue with the next video
        end
      end

      if target_path.exist?
        # Add the processed video to our concat list
        concat_entries << target_path.to_s
      else
        failed "Rendering failed for #{video.title}"
        raise "Rendering failed for #{video.title}"
      end
    end

    concat_entries
  end

  def concat_videos_to_mp4(video_files)
    # Create a unique output filename for this playlist
    output_filename = "playlist_#{@playlist.id}_#{SecureRandom.urlsafe_base64(8)}.mp4"
    output_dir = Rails.root.join('public', 'streams', @playlist.channel.stream_path, @playlist.id.to_s)
    output_path = output_dir.join(output_filename)

    # Create an output directory if it doesn't exist
    FileUtils.mkdir_p(output_dir.to_s) unless output_dir.exist?

    # Create an input file list for concatenation
    # Note: The actual concatenation command will use these files directly
    logger.info "Concatenating #{video_files.size} videos into #{output_path}"
    at(0.9, 1, 'Concatenating videos to final MP4 file')

    if video_files.size == 1
      # For a single file, we can just use direct input
      input_file = video_files.first
      cmd = format('ffmpeg -f mpegts -i %s -c copy -bsf:a aac_adtstoasc -f mp4 %s',
                    shesc(input_file), shesc(output_path.to_s))
    else
      # # For multiple files, we need to create a concat list
      # concat_file = File.join(Rails.root.join('tmp', 'streams', job_id), 'concat.txt')
      # File.open(concat_file, 'w') do |f|
      #   video_files.each do |video_path|
      #     f.puts "file '#{video_path}'"
      #   end
      # end

      concat_params = "concat:#{video_files.join('|')}"

      # Use the concat demuxer format
      cmd = format('ffmpeg -f mpegts -i %s -c copy -bsf:a aac_adtstoasc -f mp4 %s',
                    shesc(concat_params), shesc(output_path.to_s))
    end

    logger.debug "Running concat command: #{cmd}"

    # Execute the command with IO.popen to capture output
    output = nil

    begin
      # Execute the command and capture the output
      IO.popen(cmd, err: %i[child out]) do |io|
        output = io.read
      end
      status = $CHILD_STATUS.success?

      if status
        logger.info "Successfully concatenated #{video_files.size} videos for playlist #{@playlist.id}"

        # Update the playlist with the relative path if needed
        relative_path = output_path.to_s.sub(Rails.public_dir.to_s, '').sub(%r{^/}, '')
        if @playlist.respond_to?(:output_path=)
          @playlist.update_column(:output_path, relative_path)
        end

        completed "Playlist rendered to #{output_filename}"

      else
        logger.error "Failed to concatenate videos. FFMPEG output: #{output}"
        failed 'Failed to concatenate videos. See logs for details.'
      end
    rescue StandardError => e
      logger.error "Exception while concatenating videos: #{e.message}\n#{e.backtrace.join("\n")}"
      failed "Failed to concatenate videos: #{e.message}"
    end
  end

  def shesc(str)
    Shellwords.escape(str)
  end
end
