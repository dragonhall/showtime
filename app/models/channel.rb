class Channel < ApplicationRecord
  has_many :playlists
  has_and_belongs_to_many :groups
  has_many :admins, through: :groups

  has_many :recordings

  belongs_to :trailer_before, class_name: 'Video'
  belongs_to :trailer_after, class_name: 'Video'


  mount_uploader :icon, ChannelImageUploader
  mount_uploader :logo, ChannelImageUploader

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :trailer_before
  validates_presence_of :trailer_after

  #validate :trailer_presence, if: Proc.new { trailer_before_id? && trailer_after_id? }

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

  def trailer_presence
    errors.add(:trailer_before) unless Video.where(id: self.trailer_before_id).any?
    errors.add(:trailer_after) unless Video.where(id: self.trailer_after_id).any?
  end
end
