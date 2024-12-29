class AddVideoTypeToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :video_type, :integer

    reversible do |dir|
      dir.up do
        update "UPDATE tracks SET video_type = (SELECT video_type FROM videos WHERE videos.id = tracks.video_id)"
      end
    end
  end
end
