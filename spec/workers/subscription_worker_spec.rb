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
  let(:subscription) { subscriber.subscription }
  let(:token) { 'tok_1234' }

  describe '#perform_async' do
    context "when the job hasn't run" do
      let(:stripe_response) { double("Stripe::Response") }
      let(:stripe_subscription_id) { 'sub_1234' }

      it "updates user's Stripe::Customer record" do
        expect(User).to receive(:find).and_return(subscriber)
        expect(subscriber).to receive(:update_stripe).with(source: token, email: subscriber.email)
        expect(subscription).to receive(:activate)
        expect(subscription).to receive(:inactive?).and_return(true)
        subject.perform_async(subscriber.id, token)
      end
    end
  end
end
