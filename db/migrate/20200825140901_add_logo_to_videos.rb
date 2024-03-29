# frozen_string_literal: true

class AddLogoToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :logo, :boolean, default: true
  end
end
