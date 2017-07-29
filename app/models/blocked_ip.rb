class BlockedIp < ApplicationRecord

  validates_uniqueness_of :address, allow_blank: false
end
