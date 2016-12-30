FactoryGirl.define do
  factory :payment_method do
    stripe_token Faker::Lorem.characters(20)
  end
end
