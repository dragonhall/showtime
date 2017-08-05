class AddSeriesToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :series, :string
    add_index :videos, :series
  end
end
