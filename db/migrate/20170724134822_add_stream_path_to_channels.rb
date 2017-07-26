class AddStreamPathToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :stream_path, :string
  end
end
