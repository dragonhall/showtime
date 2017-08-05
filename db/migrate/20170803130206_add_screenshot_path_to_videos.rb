class AddScreenshotPathToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :screenshot_path, :string
  end
end
