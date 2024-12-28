# frozen_string_literal: true

class AddChannelGroupsAssociation < ActiveRecord::Migration[5.1]
  def change
    create_table :channels_groups do |t|
      t.integer :channel_id
      t.integer :group_id
    end
  end
end
