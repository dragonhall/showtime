# frozen_string_literal: true

class BlockedIp < ApplicationRecord
  validates_uniqueness_of :address, allow_blank: false, case_sensitive: false
end
