# frozen_string_literal: true

namespace :videos do
  task guess_series: :environment do
    Video.films.each do |v|
      next unless v.series.blank? && v.metadata[:title]

      series = v.metadata[:title].scan(/\A(.+?)\s+\d+/).flatten.first
      unless series.blank?
        warn " * Detected #{series} for [#{v.metadata[:title]}]"
        v.update_attribute :series, series
      end
    end
  end

  task reimport: :environment do
    if ENV['VIDEO_ID'].blank?
      abort 'Please set VIDEO_ID to which video should be reimported. E.g.: rake videos:reimport VIDEO_ID=123'
    end
    if Video.where(id: ENV['VIDEO_ID'].to_i).any?
      video = Video.find(ENV['VIDEO_ID'].to_i)
      video.update_attribute :metadata, {}
      VideoImportJob.perform_later video.path
      warn " * Video [#{File.basename(video.path)}] enqueued to reimport"
    end
  end
end
