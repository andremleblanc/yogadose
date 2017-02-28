class SubscriptionWorker
  include Sidekiq::Worker
  PLAN = 'standard'.freeze

  def perform(user_id, stripe_token)
    user = User.find(user_id)
    user.payment_methods.create!(stripe_token: stripe_token) unless user.payment_methods.where(stripe_token: stripe_token).present?
    user.update!(stripe_id: create_stripe_customer(user, stripe_token).id) unless user.stripe_id.present?
  end

  private

  def create_stripe_customer(user, stripe_token)
    Stripe::Customer.create(
      {
        email: user.email,
        plan: PLAN,
        source: stripe_token,
        trial_end: user.subscription.trial_expiry.to_i
      }
    )
  end
end
