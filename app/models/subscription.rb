class Subscription < ApplicationRecord
  CANCELLING = 'cancelling'.freeze
  CANCELLED = 'cancelled'.freeze

  belongs_to :user
  validates :user, uniqueness: true

  def cancel_subscription
    stripe_subscription ? stripe_subscription.delete(at_period_end: true) : nil
  end

  def next_charge
    @next_charge ||= stripe_subscription && status != CANCELLED ?
        Time.at(stripe_subscription.current_period_end).advance(days: 1).beginning_of_day :
        nil
  end

  def payment_method
    user.default_source
  end

  def status
    return CANCELLED unless stripe_subscription
    stripe_subscription.canceled_at ? CANCELLING : stripe_subscription.status
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
