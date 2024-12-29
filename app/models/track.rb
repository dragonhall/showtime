# frozen_string_literal: true

class Track < ApplicationRecord

  # XXX Ensure this enum is matches with Video#video_type otherwise playlist editor will break!
  enum video_type: %i[film trailer advert intro rollover]

  belongs_to :playlist
  belongs_to :video

  validate :playlist_not_finalized, if: :playlist

  scope :now_playing, -> { where(playing: true) }

  scope :films, -> { joins(:video).where('videos.video_type' => Video.video_types[:film]) }

  # default_scope -> { includes(:video).order(:playlist_id, :position) }

  validates_presence_of :video
  validates_presence_of :playlist
  validates_presence_of :title

  validates_presence_of :position
  validates_numericality_of :position, only_integer: true, greater_than: 0

  after_initialize :initialize_title
  after_initialize :initialize_position
  after_initialize :initialize_length
  after_initialize :initialize_video_type

  before_validation :initialize_title
  before_validation :initialize_video_type

  # HACK skip length refresh if we are in renumbering
  before_save :refresh_length, unless: -> { position_changed? and not new_record? }
  after_save :recalc_playlist_duration, unless: -> { position_changed? and not new_record? }

  after_destroy :renumber_playlist

  # @return [Integer] Returns length (in seconds) of the contained video
  #                   plus - if set - the length of the intro/outro of the playlist
  # def length
  #   @length ||= video.metadata['length'] || 0
  # end

  def stop!
    update_attribute :playing, false
  end

  def up!
    return if position <= 1

    oldpos = position.nil? || position.zero? ? 1 : position
    prtrack = playlist.tracks.where('tracks.position < ?', oldpos).order(position: 'ASC').last

    update_attribute :position, prtrack.position
    prtrack.update_attribute :position, oldpos
  end

  def down!
    return if position >= playlist.tracks.size

    oldpos = position.nil? || position.zero? ? 1 : position
    nxtrack = playlist.tracks.where('tracks.position > ?', oldpos).order(position: 'ASC').first
    update_attribute :position, nxtrack.position
    nxtrack.update_attribute :position, oldpos
  end

  def start_time
    @start_time ||= playlist.start_time + before_me
  end

  def end_time
    @end_time ||= playlist.start_time + before_me + length
  end

  private

  def playlist_not_finalized
    # XXX Warning: we MUST check the database state instead of real state to work around validation error during
    # finalizing the playlist
    # TODO Create tests for this
    errors.add(:playlist, 'A műsor nem lehet lezárva') if !playlist.blank? && playlist.finalized_in_database
  end

  def initialize_title
    self.title = video.metadata['title'] if title.blank? && video
  end

  def initialize_video_type
    self.video_type = video.video_type if video_type.blank? && video
  end

  def initialize_position
    self.position = playlist.tracks.count + 1 if position.nil? && playlist
    self.position = 1 if position.zero?
  end

  def initialize_length
    return if length > 0 or video.blank?
    return if video.metadata.blank? or not video.metadata.key?('length')

    Rails.logger.debug "Initializing track length"
    self.length = video.metadata['length']
    Rails.logger.debug "Length set to #{length}"
  end


  def before_me
    # @before_me ||= playlist.tracks.where('tracks.position < ?', position).all.map(&:length).sum
    @before_me ||= playlist.tracks.where('position < ?', position).sum(:length)
  end

  def recalc_playlist_duration
    playlist.send :calculate_duration if playlist_id?
  end

  def renumber_playlist
    playlist.reload.renumber!
  end

  def refresh_length
    Rails.logger.debug "Refreshing track length"
    if new_record? or ( not video.blank? and video.updated_at > updated_at ) then
      self.length = video.metadata['length']
      Rails.logger.debug "Length set to #{length}"
    end
  end
end
