require 'faker'

FactoryBot.define do
  factory :playlist do
    channel
    title { Faker::Lorem.sentence }
    start_time { Faker::Time.forward(days: 30) }
    intro 
    finalized { false }
    published { false }
  end
end
