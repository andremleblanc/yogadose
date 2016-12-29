class Subscription < ApplicationRecord
  belongs_to :user
  validates :token, presence: true
  validates :user, uniqueness: true

  def trial_expiry
    @trial_expiry ||= created_at.advance(days: 7).end_of_day
  end
end
