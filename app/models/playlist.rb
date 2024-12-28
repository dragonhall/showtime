# frozen_string_literal: true

class PlaylistHasNoTracksError < StandardError; end

class Playlist < ApplicationRecord
  belongs_to :channel
  has_many :tracks, dependent: :destroy

  belongs_to :intro, class_name: 'Video'

  scope :finalized, -> { where(finalized: true) }
  scope :wip, -> { where(finalized: false) }

  scope :at_today, lambda {
                     where('playlists.start_time >= ? AND playlists.start_time <= ?',
                              Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
                   }
  scope :at_week, lambda {
                    where('playlists.start_time >= ? AND playlists.start_time <= ?',
                             Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
                  }

  scope :active, -> { joins(:tracks).where('tracks.playing = ?', true) }
  scope :upcoming, -> { where(finalized: true).where('playlists.start_time >= ?', Time.zone.now - 2.weeks) }
  scope :current, lambda {
                    where('playlists.start_time BETWEEN ? AND ?',
                          Time.zone.now.beginning_of_week,
                          Time.zone.now.end_of_week)
                  }

  default_scope -> { includes(:tracks).order(start_time: 'ASC') }

  validates_presence_of :title
  validates_presence_of :start_time
  validates_uniqueness_of :start_time, case_sensitive: false, scope: :channel

  before_save :calculate_duration
  after_initialize :initialize_title

  before_update :finalize!, if: :finalized?
  after_update :postprocess_finalization, if: :saved_change_to_finalized?

  def active?
    tracks.where(playing: true).any?
  end

  def finalize!
    logger.debug "Finalizing playlist #{title}"
  end

  def wrap_films!
    if tracks.any? then
      # First we make sure all tracks contain continuous positions. It's needed because next
      # calculations are based on there is no gap between position ids
      renumber!

      video_list = tracks.collect(&:video)

      tracks.delete_all

      video_list.each do |video|
        if video.film?
          tracks.create!(video_id: channel.trailer_after_id) if channel.trailer_after_id?
          tracks.create!(video_id: intro_id)
          tracks.create!(video_id: video.id)
          tracks.create!(video_id: intro_id)
          tracks.create!(video_id: channel.trailer_before_id) if channel.trailer_before_id?
        else
          tracks.create!(video_id: video.id)
        end
      end
    else
      raise PlaylistHasNoTracksError, 'No tracks added to the tracklist'
    end
  end

  def end_time
    start_time + duration
  end

  def program_as_json
    {
      title: title,
      start_time: start_time,
      end_time: end_time,
      tracks: {}
    }
  end

  def stop
    tracks.where(playing: true).each(&:stop!)
  end

  def renumber!
    tracks.each_with_index do |track, i|
      index = i + 1 # Start numbering from 1
      unless track.position == index then
        track.update_attributes position: index
      end
    end
  end

  def shift_from!(position)
    tracks.where('position > ?', position).each do |track|
      logger.debug "Shifting '#{track.title}' (#{track.position} => #{track.position + 1})"
      track.update_attributes position: track.position + 1
    end
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

  def program_path
    "/programs/channel_#{channel.id}/#{id}/#{start_time.strftime('%F_%H-%M')}.png"
  end

  def program?
    Rails.public_dir.join(program_path.sub(%r{^/}, '')).exist?
  end

  def human_title
    if !defined?(@human_title) || @human_title.blank?
      @human_title = if start_time.to_date == Time.zone.now.to_date then
                       'Mai'
                     elsif start_time.to_date == (Time.zone.now - 1.day).to_date then
                       'Tegnapi'
                     elsif start_time.to_date == (Time.zone.now + 1.day).to_date then
                       'Holnapi'
                     elsif start_time >= Time.zone.now.to_date.beginning_of_week &&
                           start_time <= Time.zone.now.to_date.end_of_week then
                       # 'Heti'
                       I18n.l(start_time, format: '%Ai').titleize
                     elsif start_time >= 7.days.from_now.to_date.beginning_of_week &&
                           start_time <= 7.days.from_now.to_date.end_of_week then
                       'Jövő Heti'
                     else
                       start_time > Time.now.end_of_day ? 'Következő' : 'Előző'
                     end
      @human_title = 'Mai' if Rails.application.class.name.downcase.match?(/showtime/)
      @human_title += ' Műsor'
    end
    @human_title
  end

  private

  def calculate_duration
    self.duration = tracks.collect(&:length).sum
  end

  def initialize_title
    # rubocop:disable Layout/LineLength
    self.title ||= "#{channel ? channel.name : Playlist.model_name} ##{channel.playlists.last.blank? ? 1 : channel.playlists.last.id + 1}" if new_record?
    # rubocop:enable Layout/LineLength
  end

  def postprocess_finalization
    return unless finalized?

    PlaylistGeneratorJob.perform_later id
    # There was multiple issues when self was used here instead of class name
    # rubocop:disable Style/RedundantSelf
    Resque.enqueue_at self.start_time, StreamingJob, playlist_id: id
    # rubocop:enable Style/RedundantSelf

    recording_valid = (start_time + 4.days).to_date.to_time

    tracks.collect(&:video).find_all(&:recordable?).each do |v|
      unless Recording.where(video_id: v.id).any?
        Recording.create(video_id: v.id, channel: channel, valid_from: recording_valid, expires_at: nil)
      end
    end
  end
end
