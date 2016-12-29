FactoryGirl.define do
  factory :payment_method do
    token Faker::Lorem.characters(20)
  end
end
