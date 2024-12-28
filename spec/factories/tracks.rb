# frozen_string_literal: true

FactoryBot.define do
  factory :tracks do
    playlist_id { 1 }
    video_id { 'MyString' }
    integer { 'MyString' }
    title { 'MyString' }
    position { 1 }
  end
end
