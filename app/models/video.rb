class Video < ApplicationRecord
  # PEGI_RATINGS = [3,7,12,16,18]

  enum video_type: %i[film trailer advert intro]

  enum pegi_rating: [3, 7, 12, 16, 18].map { |r| "pegi_#{r}".to_sym }

  # serialize :metadata, JSON
  serialize :metadata, JsonWithIndifferentAccessSerializer
  store_accessor :metadata, :title, :width, :height,
                 :frame_rate, :bitrate, :deinterlace, :length

  validates_presence_of :path
  validates_uniqueness_of :path

  validates_presence_of :pegi_rating
  validates_inclusion_of :pegi_rating, in: Video.pegi_ratings.keys

  validates_inclusion_of :video_type, in: Video.video_types.keys

  # validates_length_of :title, maximum: 20

  has_many :tracks
  has_many :recordings

  after_create :prepare_for_import

  after_save :update_tracks, if: :saved_change_to_metadata?

  scope :trailers, -> { where(video_type: :trailer) }
  scope :adverts, -> { where(video_type: :advert) }
  scope :films, -> { where(video_type: :film) }
  scope :intros, -> { where(video_type: :intro) }

  def imported?
    !metadata.blank?
  end

  def recorded?
    Recording.where(video_id: id).any? && Recording.where(video_id: id).first.recorded?
  end

  # @return [Hash]
  def self.pegi_rating_titles
    return @pegi_ratings unless !defined?(@pegi_ratings) || @pegi_ratings.empty?
    v = Video.pegi_ratings.map do |rating, i|
      ["#{rating.to_s.sub(/^pegi_/, '')}+", i]
    end

    @pegi_rating_titles = Hash[v]
  end


  # @return [Hash]
  def self.pegi_icons
    return @pegi_icons unless !defined?(@pegi_icons) || @pegi_icons.empty?
    # v = Video.pegi_rating_titles.keys.each_with_index do |r, i|
    #   ["http://www.pegi.info/en/index/id/33/media/img/32#{i}.gif", r]
    # end

    @pegi_icons = Hash[v]
  end

  # @return [Array]
  def self.series
    @series ||= connection.exec_query(
        'SELECT DISTINCT series FROM videos'
    ).rows.flatten.compact
  end

  # @param [Playlist] playlist
  def record!(playlist)
    recording = recordings.create!(valid_from: playlist.start_time, channel_id: playlist.channel.id)
  end

  # @return [FFMPEG::Movie] FFMPEG movie
  def to_movie
    @movie ||= FFMPEG::Movie.new(path) if File.exist?(path)
  end

  private

  def prepare_for_import
    VideoImportJob.perform_later path
    VideoPreviewJob.perform_later id
  end

  def update_tracks
    tracks.each do |track|
      next if track.playlist && track.playlist.finalized?
      track.title = metadata[:title]
      track.save
    end
  end
end
