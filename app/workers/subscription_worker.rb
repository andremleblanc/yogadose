class SubscriptionWorker
  include Sidekiq::Worker
  PLAN = 'standard'.freeze

  def perform(user_id, stripe_token)
    user = User.find(user_id)
    user.create_payment_method!(stripe_token: stripe_token) unless user.payment_method.present?
    user.update!(stripe_id: create_stripe_customer(user).id) unless user.stripe_id.present?
  end

  private

  def create_stripe_customer(user)
    Stripe::Customer.create(
      {
        email: user.email,
        plan: PLAN,
        source: user.payment_method.stripe_token,
        trial_end: user.subscription.trial_expiry.to_i
      }
    )
  end
end
