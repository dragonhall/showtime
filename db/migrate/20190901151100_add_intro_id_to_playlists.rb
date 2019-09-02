class AddIntroIdToPlaylists < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :intro_id, :integer
  end
end
