class AddLengthToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :length, :integer, default: 0

    reversible do |dir|
      dir.up do
        update "UPDATE tracks SET length = (SELECT JSON_VALUE(metadata, '$.length') FROM videos WHERE videos.id = tracks.video_id)"
        update "UPDATE tracks SET length = 0 WHERE length IS NULL" # HACK JSON_VALUE unfortunately NULLs length if no matching videos
      end
    end
  end
end
