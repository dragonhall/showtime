require 'faker'

FactoryBot.define do
  factory :video do
    #path { Faker::File.file_name(dir: '/szeroka/dh0/load/load3/letoltesek/anime/sorozat', ext: 'mp4') }
    path do
      _base = Faker::Name.name.downcase.sub(/[^a-z ]+/, '').sub(/\s+/, '_')
      "/szeroka/dh0/load/load3/letoltesek/anime/sorozat/#{_base}.mp4"
    end
    metadata {
      {
          'title' => Faker::Book.title,
          'length' => rand(1..45).minutes
      }
    }
    pegi_rating { Video.pegi_ratings.keys.shuffle.first }
  end

  factory :film, parent: :video do
    video_type { 'film' }
  end

  factory :intro, parent: :video do
    video_type { 'intro' }
    metadata {
      {
          'title' => Faker::Book.title,
          'length' => rand(15..90).seconds
      }
    }
  end

  factory :rollover, parent: :video do
    video_type { 'rollover' }
    metadata {
      {
          'title' => Faker::Book.title,
          'length' => rand(15..90).seconds
      }
    }
  end

  factory :trailer, parent: :video do
    video_type { 'trailer' }
    metadata {
      {
          'title' => Faker::Book.title,
          'length' => rand(15..90).seconds
      }
    }
  end
end
