class Subscription < ApplicationRecord
  belongs_to :user
  validates :user, uniqueness: true

  def active?
    status != 'cancelled' && status !='canceled' #TODO: This doesn't work
  end

  def cancel_subscription
    stripe_subscription.delete(at_period_end: true)
  end

  def payment_method
    user.default_source
  end

  def status
    stripe_subscription.status #TODO: Cache
  end

  def stripe_subscription
    @stripe_subscription ||= Stripe::Subscription.retrieve(stripe_id) #TODO: Handle this raising an error
  end

  def trial_expiry
    @trial_expiry ||= created_at.advance(days: 7).end_of_day
  end
end
