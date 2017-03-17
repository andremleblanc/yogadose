class Subscription < ApplicationRecord
  CANCELLING = 'cancelling'.freeze
  CANCELLED = 'cancelled'.freeze
  PLAN = 'standard'.freeze

  belongs_to :user
  validates :user, uniqueness: true

  # TODO: Simplify status logic
  # inactive? = cancelled or new
  # cancelling? = will cancel at end of cycle
  # active? = not inactive or cancelling
  # use these in activate
  def activate
    return false if user.stripe_customer.blank?

    case status
      when CANCELLING
        stripe_subscription.plan = PLAN
        stripe_subscription.save
      when CANCELLED
        sub = Stripe::Subscription.create(
            customer: user.stripe_id,
            plan: PLAN,
            trial_end: trial_expiry.to_i
        )
        update!(stripe_id: sub.id)
      else
        return false
    end

    true
  end

  def cancel_subscription
    stripe_subscription ? stripe_subscription.delete(at_period_end: true) : nil
  end

  def active?
    !cancelled?
  end

  def cancelled?
    [CANCELLED, CANCELLING].include? status
  end
  alias_method :inactive?, :cancelled?

  def next_charge
    @next_charge ||= stripe_subscription && status != CANCELLING ?
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
