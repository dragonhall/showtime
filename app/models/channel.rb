class Channel < ApplicationRecord
  has_many :playlists
  has_and_belongs_to_many :groups
  has_many :admins, through: :groups

  has_many :recordings


  mount_uploader :icon, ChannelImageUploader
  mount_uploader :logo, ChannelImageUploader

  validates_presence_of :name
  validates_uniqueness_of :name

  after_create :permit_fulladmins

  def url
    'http:// ' + self.domain
  end


  private

  def permit_fulladmins
    unless self.group_ids.include?(Group.pluck(:id).first) then
      groups << Group.where(name: 'FullAdmin').first
    end
  end
end
