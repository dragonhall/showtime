class Group < ApplicationRecord
  has_and_belongs_to_many :channels
  has_many :admins
end
