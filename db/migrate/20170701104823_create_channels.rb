# frozen_string_literal: true

class CreateChannels < ActiveRecord::Migration[5.1]
  def change
    create_table :channels do |t|
      t.string :name
      t.string :icon
      t.string :logo
      t.string :domain

      t.timestamps
    end
  end
end
