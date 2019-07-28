FactoryBot.define do
  factory :playlist do
    channel_id { 1 }
    title { "MyString" }
    start_time { "2017-07-01 14:14:46" }
    duration { 1 }
    finalized { false }
    published { false }
  end
end
