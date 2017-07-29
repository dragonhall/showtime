class PlaylistHasNoTracksError < StandardError; end

class Playlist < ApplicationRecord
  belongs_to :channel
  has_many :tracks

  scope :finalized, -> { where(finalized: true) }
  scope :wip, -> { where(finalized: false) }
  scope :at_today, -> { where('playlists.start_time >= ? AND playlists.start_time <= ?', Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day) }
  # scope :active, -> { where ('playlists.start_time <= NOW() AND playlists.start_time + INTERVAL playlists.duration SECOND != NOW()') }
  scope :active, -> { joins(:tracks).where('tracks.playing = ?', true) }
  scope :upcoming, -> { where('playlists.start_time >= NOW()').where(finalized: true) }

  validates_presence_of :title
  validates_presence_of :start_time
  validates_uniqueness_of :start_time

  before_save :calculate_duration
  after_initialize :initialize_title

  after_update :postprocess_finalization, if: :saved_change_to_finalized?

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

  def stop
    tracks.where(playing: true).each(&:stop!)
  end

  def stream_to_technical
    StreamingJob.perform_later clone_to_technical
  end

  def clone_to_technical
    unless Channel.where(domain: '#technical').any?
      Channel.create(
          name: 'Technical channel',
          domain: '#technical',
          stream_path: 'dragonhall_teszt',
          icon: nil, logo: nil
      )
    end

    # Do not clone itself to technical if we are already on technical channel
    if channel.domain == '#technical'
      self
    else
      new_playlist = Channel.where(domain: '#technical').first.playlists.create(
          title: "Playlist##{id}",
          start_time: 1.minutes.from_now
      )

      tracks.each do |track|
        new_playlist.tracks.create(video: track.video)
      end

      new_playlist.save

      new_playlist
    end
  end

  private

  def calculate_duration
    self.duration = tracks.collect(&:length).sum
  end

  def initialize_title
    self.title ||= "#{channel ? channel.name : Playlist.model_name} ##{Playlist.last.blank? ? 1 : Playlist.last.id + 1}" if new_record?
  end

  def postprocess_finalization
    PlaylistGeneratorJob.perform_later id
    Resque.enqueue_at_with_queue 'streaming', self.start_time, StreamingJob, self.id
  end
end
