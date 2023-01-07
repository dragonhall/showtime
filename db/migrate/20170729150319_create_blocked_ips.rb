# frozen_string_literal: true

class CreateBlockedIps < ActiveRecord::Migration[5.1]
  def change
    create_table :blocked_ips do |t|
      t.string :address, nil: false

      t.timestamps
    end

    add_index :blocked_ips, :address, unique: true
  end
end
