# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    pwd = SecureRandom.hex(32)
    name { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { pwd }
    password_confirmation { pwd }
    group
  end
end
