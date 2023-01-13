# frozen_string_literal: true

class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.integer :playlist_id, null: false
      t.integer :video_id, null: false
      t.string :title, null: false
      t.integer :position, null: false
      t.boolean :playing
      t.timestamps
    end
  end
end
