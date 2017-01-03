FactoryGirl.define do
  factory :routine do
    title Faker::Lorem.sentence
    source Faker::Internet.url
  end
end
