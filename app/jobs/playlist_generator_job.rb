require 'fileutils'

class PlaylistGeneratorJob < ApplicationJob
  queue_as :default

  before_perform do
    FileUtils.mkdir_p(Rails.root.join('public', 'programs').to_s)
  end

  def perform(playlist_id)
    program_root = Rails.root.join('public', 'programs')

    playlist = begin
                 playlist_id.is_a?(Playlist) ? playlist_id : Playlist.find(playlist_id)
               rescue
                 nil
               end
    unless playlist
      failed("Playlist##{playlist_id} not found")

      return
    end

    kit = IMGKit.new(
        channel_playlist_tracks_url(
            playlist.channel,
            playlist.id
        )
    )

    FileUtils.mkdir_p(program_root.join("channel_#{playlist.channel_id}/#{playlist.id}"))

    File.open(program_root.join("channel_#{playlist.channel_id}/#{playlist_id}")
         .join("#{playlist.start_time.to_date.strftime('%Y-%m-%d')}.png"), 'wb') do |fp|
      fp.write kit.to_png.force_encoding(::Encoding::ASCII_8BIT)
    end
  end
end
