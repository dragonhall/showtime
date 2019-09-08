require 'faker'

FactoryBot.define do
  factory :video, aliases: [:intro] do
    #path { Faker::File.file_name(dir: '/szeroka/dh0/load/load3/letoltesek/anime/sorozat', ext: 'mp4') }
    path do 
      _base = Faker::Name.name.downcase.sub(/[^a-z ]+/, '').sub(/\s+/, '_')
      "/szeroka/dh0/load/load3/letoltesek/anime/sorozat/#{_base}.mp4"
    end
    metadata { "" }
    pegi_rating { 'pegi_3' }
  end
end
