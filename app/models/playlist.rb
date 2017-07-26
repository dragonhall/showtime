class PlaylistHasNoTracksError < StandardError; end

class Playlist < ApplicationRecord
  belongs_to :channel
  has_many :tracks

  scope :finalized, -> { where(:finalized => true) }
  scope :wip, -> { where(:finalized => false) }
  scope :at_today, -> { where('playlists.start_time >= ? AND playlists.start_time <= ?', Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day) }
  scope :active, -> { where ('playlists.start_time <= NOW() AND playlists.start_time + INTERVAL playlists.duration SECOND != NOW()') }
  scope :upcoming, -> { where('playlists.start_time >= NOW()').where(:finalized => true) }

  validates_presence_of :title
  validates_presence_of :start_time
  validates_uniqueness_of :start_time

  before_save :calculate_duration
  after_initialize :initialize_title

  after_update :postprocess_finalization, if: :finalized_changed?

  def finalize!
    if tracks.count > 0 then
      update_attribute :finalized, true
    else
      raise PlaylistHasNoTracksError, 'No tracks added to the tracklist'
    end
  end

  def end_time
    start_time + duration
  end

  def program_as_json
    program = {
        title: title,
        start_time: start_time,
        end_time: end_time,
        tracks: {}
    }
  end

  private

  def calculate_duration
    self.duration = tracks.collect(&:length).sum
  end

  def initialize_title
    self.title = "#{channel ? channel.name : Playlist.model_name} ##{Playlist.last.blank? ? 1 : Playlist.last.id + 1}" if new_record?
  end

  def postprocess_finalization
    PlaylistGeneratorJob.perform_later self.id
  end

end
