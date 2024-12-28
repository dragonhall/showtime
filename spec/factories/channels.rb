# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    name { 'MyString' }
    # trailer_before { build :video }
    # trailer_after { build :video }
    association :trailer_before, factory: :video, video_type: Video.video_types[:intro]
    association :trailer_after, factory: :video, video_type: Video.video_types[:intro]
  end
end
