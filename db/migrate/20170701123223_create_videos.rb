class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :videos do |t|
      t.string :path
      t.text :metadata
      t.integer :video_type, default: 0, null: false
      t.timestamps
    end

    add_index :videos, :path, unique: true
  end
end
