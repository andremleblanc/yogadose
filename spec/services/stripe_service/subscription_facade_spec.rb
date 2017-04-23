require 'rails_helper'

RSpec.describe StripeService::SubscriptionFacade do
  subject { StripeService::SubscriptionFacade.new(customer) }
  let(:customer) { double('Stripe::Customer') }

  describe '#active?' do
    let(:subscription) { double('Stripe::Subscription') }
    let(:result) { subject.active? }

    context 'when inactive' do
      it 'returns false' do
        expect(subject).to receive(:inactive?).and_return(true)
        expect(result).to be false
      end
    end

    context 'when cancelling' do
      it 'returns true' do
        allow(subject).to receive(:cancelling?).and_return(true)
        allow(subject).to receive(:inactive?).and_return(false)
        expect(result).to be true
      end
    end

    context 'when not inactive or cancelling' do
      it 'returns true' do
        allow(subject).to receive(:cancelling?).and_return(false)
        allow(subject).to receive(:inactive?).and_return(false)
        expect(result).to be true
      end
    end
  end

  describe '#cancel_subscription' do
    xit 'does something'
  end

  describe '#cancelling?' do
    let(:result) { subject.cancelling? }

    context 'when cancelled_at blank' do
      let(:customer) { Stripe::Customer.retrieve('cus_AM1SRrH9GXWrnH') }

      it 'returns false' do
        VCR.use_cassette('services/stripe_service/subscription_facade/active') do
          expect(result).to be false
        end
      end
    end

    context 'when cancelled_at present' do
      let(:customer) { Stripe::Customer.retrieve('cus_AM1SCrXT52MDXI') }

      it 'returns true' do
        VCR.use_cassette('services/stripe_service/subscription_facade/cancelling') do
          expect(result).to be true
        end
      end
    end
  end

  describe '#inactive?' do
    let(:result) { subject.inactive? }

    context 'when subscription blank' do
      let(:customer) { Stripe::Customer.retrieve('cus_AM1MkMSrPqCmIG') }

      it 'returns true' do
        VCR.use_cassette('services/stripe_service/subscription_facade/inactive') do
          expect(result).to be true
        end
      end
    end

    context 'when subscription present' do
      let(:customer) { Stripe::Customer.retrieve('cus_AM1SRrH9GXWrnH') }

      it 'returns false' do
        VCR.use_cassette('services/stripe_service/subscription_facade/active') do
          expect(result).to be false
        end
      end
    end
  end

  describe '#next_charge' do
    xit 'does something'
  end

  describe '#reactivate' do
    xit 'does something'
  end
end