require 'rails_helper'

RSpec.describe SubscriptionWorker, type: :worker do
  before do
    Sidekiq::Testing.inline!
  end

  after do
    Sidekiq::Testing.fake!
  end

  subject { SubscriptionWorker }
  let(:subscriber) { create(:subscriber) }
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

  describe '#perform' do
    context 'when the job hasn\'t run' do
      it 'creates a PaymentMethod' do
        VCR.use_cassette('subscription_worker') do
          subject.perform_async(subscriber.id, token)
        end
        expect(PaymentMethod.find_by(stripe_token: token)).to be
      end
    end

    context 'when the payment method has already been created' do
      pending
    end
  end
end
