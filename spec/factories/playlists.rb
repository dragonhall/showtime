FactoryBot.define do
  factory :playlist do
    channel
    title { "MyString" }
    start_time { Time.zone.now }
    finalized { false }
    published { false }
  end
end
