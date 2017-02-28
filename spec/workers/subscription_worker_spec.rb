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
  let(:token) {
    Stripe::Token.create(
      card: {
        number: '4242424242424242',
        exp_month: Time.now.strftime('%m'),
        exp_year: Time.now.advance(years: 1).strftime('%Y'),
        cvc: '314'
      },
    ).id
  }

  describe '#perform_async' do
    let(:perform_async) do
      VCR.use_cassette('subscription_worker') do
        subject.perform_async(subscriber.id, token)
      end
    end

    context "when the job hasn't run" do
      it 'creates a PaymentMethod' do
        perform_async
        expect(PaymentMethod.find_by(stripe_token: token)).to be
      end

      it 'updates the user' do
        perform_async
        subscriber.reload
        expect(subscriber.stripe_id).to be
      end
    end

    context 'when a payment method with the same token has already been created' do
      let(:subscriber) { create(:subscriber) }

      before do
        subscriber.payment_methods.create(attributes_for(:payment_method, stripe_token: token))
      end

      it "doesn't call create_payment_method" do
        expect{ perform_async }.not_to change{ PaymentMethod.count }
      end
    end

    context 'when the user has already been updated' do
      let(:subscriber) { create(:subscriber, stripe_id: Faker::Lorem.characters(20)) }

      it "doesn't make a call to Stripe" do
        expect_any_instance_of(subject).not_to receive(:create_stripe_customer)
        perform_async
      end
    end
  end
end
