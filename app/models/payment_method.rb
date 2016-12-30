class PaymentMethod < ApplicationRecord
  belongs_to :user
  validates :stripe_token, presence: true
end
