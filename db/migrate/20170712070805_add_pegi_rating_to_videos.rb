# frozen_string_literal: true

class AddPegiRatingToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :pegi_rating, :integer
  end
end
