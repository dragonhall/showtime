class AddMultiToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :multi, :boolean
  end
end
