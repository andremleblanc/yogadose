FactoryGirl.define do
  factory :user do
    admin Faker::Boolean.boolean
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password Faker::Internet.password(8)

    trait :with_image do
      image Faker::Internet.url
    end

    factory :subscriber do
      admin false
      stripe_id 'cus_1234'
    end
  end
end
