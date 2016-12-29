class Subscription < ApplicationRecord
  belongs_to :user
  validates :token, presence: true
  validates :user, uniqueness: true
end
