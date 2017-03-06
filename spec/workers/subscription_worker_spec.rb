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
      it "updates user's Stripe::Customer record" do
        expect(User).to receive(:find).and_return(subscriber)
        expect(subscriber).to receive(:update_stripe).with(
            source: token,
            email: subscriber.email,
            plan: SubscriptionWorker::PLAN,
            trial_end: subscriber.subscription.trial_expiry.to_i
        )
        subject.perform_async(subscriber.id, token)
      end
    end
  end
end
