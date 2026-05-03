# frozen_string_literal: true

class AddPlayingToPlaylists < ActiveRecord::Migration[6.1]
  def change
    add_column :playlists, :playing, :boolean
  end
end
