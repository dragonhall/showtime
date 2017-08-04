class AddRecordableToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :recordable, :boolean
  end
end
