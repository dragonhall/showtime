class Track < ApplicationRecord
  belongs_to :playlist
  belongs_to :video

  validate :playlist_not_finalized, if: :playlist

  scope :now_playing, -> { where(playing: true) }

  scope :films, -> { joins(:video).where('videos.video_type' => Video.video_types[:film]) }

  default_scope -> { includes(:video).order(:playlist_id, :position) }

  validates_presence_of :video
  validates_presence_of :playlist
  validates_presence_of :title

  validates_presence_of :position
  validates_numericality_of :position, only_integer: true, greater_than: 0

  after_initialize :initialize_title
  after_initialize :initialize_position
  before_validation :initialize_title

  after_save :recalc_playlist_duration

  after_destroy :renumber_playlist

  def length
    video.metadata['length'] || 0
  end

  def stop!
    update_attribute :playing, false
  end

  def up!
    return if position <= 1

    oldpos = position.nil? || position == 0 ? 1 : position
    prtrack = playlist.tracks.where('tracks.position < ?', oldpos).order(position: 'ASC').last

    update_attribute :position, prtrack.position
    prtrack.update_attribute :position, oldpos
  end

  def down!
    return if position >= playlist.tracks.size

    oldpos = position.nil? || position == 0 ? 1 : position
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
    errors.add(:base, 'A műsor nem lehet lezárva') if !playlist.blank? && playlist.finalized?
  end

  def initialize_title
    self.title = video.metadata['title'] if title.blank? && video
  end

  def initialize_position
    self.position = playlist.tracks.size + 1 if position.nil? && playlist
  end

  def before_me
    @before_me ||= playlist.tracks.where('tracks.position < ?', position).all.map(&:length).sum
  end

  def recalc_playlist_duration
    playlist.send :calculate_duration if playlist_id?
  end

  def renumber_playlist
    playlist.renumber!
  end
end
