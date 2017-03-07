class Subscription < ApplicationRecord
  CANCELLED = 'cancelled'.freeze

  belongs_to :user
  validates :user, uniqueness: true

  def active?
    stripe_subscription.present?
  end

  def cancel_subscription
    stripe_subscription ? stripe_subscription.delete(at_period_end: true) : nil
  end

  def payment_method
    user.default_source
  end

  def status
    stripe_subscription ? stripe_subscription.status : CANCELLED #TODO: Cache, burst on period end
  end

  def stripe_subscription
    return @stripe_subscription if defined?(@stripe_subscription)
    @stripe_subscription ||= begin
      Stripe::Subscription.retrieve(stripe_id) #TODO: Handle this raising an error
    rescue Stripe::InvalidRequestError
      nil
    end
  end

  def trial_expiry
    @trial_expiry ||= created_at.advance(days: 7).end_of_day
  end
end
