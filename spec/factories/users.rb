FactoryGirl.define do
  factory :user do
    admin Faker::Boolean.boolean
    name Faker::Name.name
    email Faker::Internet.email
    password Faker::Internet.password(8)

    trait :with_image do
      image Faker::Internet.url
    end

    factory :admin do
      admin true
    end

    factory :subscriber do
      admin false
      after(:build) { |subscriber| subscriber.subscription = FactoryGirl.build(:subscription, user: subscriber) }
      after(:create) { |subscriber| subscriber.subscription.save! }
    end
  end
end
