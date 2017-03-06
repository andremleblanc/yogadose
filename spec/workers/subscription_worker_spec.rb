require 'rails_helper'

RSpec.describe SubscriptionWorker, type: :worker do
  before do
    Sidekiq::Testing.inline!
  end

  after do
    Sidekiq::Testing.fake!
  end

  subject { SubscriptionWorker }
  let(:subscriber) { create(:subscriber, stripe_id: nil) }
  let(:token) { 'tok_1234' }

  describe '#perform_async' do
    context "when the job hasn't run" do
      let(:stripe_response) { double("Stripe::Response") }
      let(:stripe_subscription_id) { 'sub_1234' }

      it "updates user's Stripe::Customer record" do
        expect(User).to receive(:find).and_return(subscriber)
        expect(subscriber).to receive(:update_stripe).with(
            source: token,
            email: subscriber.email,
            plan: SubscriptionWorker::PLAN,
            trial_end: subscriber.subscription.trial_expiry.to_i
        )
        expect_any_instance_of(subject).to receive(:parse_subscription_id).and_return(stripe_subscription_id)
        subject.perform_async(subscriber.id, token)
        expect(subscriber.subscription.stripe_id).to eq stripe_subscription_id
      end
    end
  end
end
