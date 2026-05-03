# frozen_string_literal: true

class AddOutputPathToPlayLists < ActiveRecord::Migration[6.1]
  def change
    add_column :play_lists, :output_path, :string
  end
end
