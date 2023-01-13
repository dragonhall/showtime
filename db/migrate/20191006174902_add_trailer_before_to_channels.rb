# frozen_string_literal: true

class AddTrailerBeforeToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :trailer_before_id, :integer
    add_column :channels, :trailer_after_id, :integer
  end
end
