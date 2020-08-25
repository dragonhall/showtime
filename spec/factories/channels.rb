FactoryBot.define do
  factory :channel do
    name { "MyString" }
    trailer_before factory: :trailer
    trailer_after factory: :trailer
  end
end
