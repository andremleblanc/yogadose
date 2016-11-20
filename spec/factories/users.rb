FactoryGirl.define do
  factory :user do
    name Faker::Name.name
    email Faker::Internet.email
    password Faker::Internet.password(8)

    trait :with_image do
      image Faker::Internet.url
    end
  end
end
