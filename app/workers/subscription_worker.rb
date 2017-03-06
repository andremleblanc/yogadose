class SubscriptionWorker
  include Sidekiq::Worker
  PLAN = 'standard'.freeze

  def perform(user_id, stripe_token)
    user = User.find(user_id)
    customer = user.update_stripe(
        source: stripe_token,
        email: user.email,
        plan: PLAN,
        trial_end: user.subscription.trial_expiry.to_i
    )
    user.subscription.update(stripe_id: parse_subscription_id(customer))
  end

  private

  def parse_subscription_id(customer)
    customer.subscriptions.data.last.id
  end
end
