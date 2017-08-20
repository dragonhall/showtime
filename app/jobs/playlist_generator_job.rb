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
        ),
        width: 1280,
        height: 720,
        disable_smart_width: true

    )

    FileUtils.mkdir_p Rails.public_dir.join(File.dirname(playlist.program_path.sub(%r{^/}, ''))).to_s

    File.open(Rails.public_dir.join(playlist.program_path.sub(%r{^/}, '')).to_s, 'wb') do |fp|
      fp.write kit.to_png.force_encoding(::Encoding::ASCII_8BIT)
    end
  end
end
