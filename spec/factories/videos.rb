# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :video do
    path { Faker::File.file_name.sub(/\..+$/, '.mp4') }
    metadata do
      w, h = [[720, 404], [1024, 768], [1920, 1080]].sample
      {
        title: Faker::Lorem.sentence.sub(/\.$/, ''),
        length: (0..600).find_all { |i| i % 30 == 0 }.sample,
        width: w,
        height: h
      }
    end
    pegi_rating { Video.pegi_ratings.values.sample }
    video_type { Video.video_types.values.sample }
  end
end
