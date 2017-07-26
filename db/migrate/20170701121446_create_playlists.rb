class CreatePlaylists < ActiveRecord::Migration[5.1]
  def change
    create_table :playlists do |t|
      t.integer :channel_id
      t.string :title, null: false
      t.datetime :start_time, null: false
      t.integer :duration, default: 0
      t.boolean :finalized, default: false
      t.boolean :published, default: false

      t.timestamps
    end

    add_index :playlists, :start_time, unique: true
  end
end
