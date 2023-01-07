# frozen_string_literal: true

class CreateRecordings < ActiveRecord::Migration[5.1]
  def change
    create_table :recordings do |t|
      t.string :path, null: true
      t.integer :video_id, null: false
      t.datetime :valid_from, null: false
      t.datetime :expires_at, null: true
      t.integer :channel_id, null: false

      t.timestamps
    end

    add_index :recordings, :path, unique: true
    add_index :recordings, :valid_from
  end
end
