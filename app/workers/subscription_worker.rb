class SubscriptionWorker
  include Sidekiq::Worker
  def perform(user_id, stripe_token)
    user = User.find(user_id)
    user.update_stripe(source: stripe_token, email: user.email) # TODO: email needed?
    user.subscription.activate if user.subscription.inactive?
  end
end
