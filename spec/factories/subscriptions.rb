FactoryGirl.define do
  factory :subscription do
    user
    token Faker::Lorem.characters(20)
  end
end
