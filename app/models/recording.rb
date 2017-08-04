class Recording < ApplicationRecord

  scope :available, -> { where('recordings.valid_from <= NOW()').where('recordings.expires_at IS NULL OR recordings.expires_at >= ?', Time.zone.tomorrow.midnight) }

  default_scope -> { includes(:video).order(valid_from: 'DESC') }

  belongs_to :video
  belongs_to :channel

  validates_presence_of :valid_from
  validates_uniqueness_of :path, allow_blank: true

  after_create :enqueue_recording_job

  def orphaned?
    Video.where(id: video_id).none?
  end

  def recorded?
    !path.blank?
  end

  def self.series
    @series ||=     connection.exec_query(
        'SELECT DISTINCT series FROM videos  WHERE `videos`.`video_type` = 0 AND `videos`.`recordable` = 1'
    ).rows.flatten.compact
  end

  private

  def enqueue_recording_job
    RecordingJob.perform_later id
  end

end
