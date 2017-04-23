require 'rails_helper'

RSpec.describe StripeService::CustomerFacade do
  describe '.create' do
    let(:subject) { StripeService::CustomerFacade }
    let(:result) { subject.create(user) }
    let(:user) { create(:user, email: email) }
    let(:email) { 'emmanuel@pfannerstill.org' }

    it 'creates a Stripe::Customer' do
      VCR.use_cassette('stripe/create_customer') do
        expect(user.stripe_id).to be_nil
        expect(result).to be_a StripeService::CustomerFacade
        expect(result.email).to eq email
        expect(user.stripe_id).to be
      end
    end
  end

  describe '.find' do
    let(:subject) { StripeService::CustomerFacade }
    let(:result) { subject.find(id) }
    let(:id) { 'cus_AOkAEtTjYsj4Fe' }
    let(:email) { 'nicholaus@joneshintz.name' }

    it 'creates a Stripe::Customer' do
      VCR.use_cassette('services/stripe_service/customer_facade/find') do
        expect(result).to be_a StripeService::CustomerFacade
        expect(result.email).to eq email
      end
    end
  end

  describe '.find_or_create' do
    let(:subject) { StripeService::CustomerFacade }
    let(:result) { subject.find_or_create(user) }

    context 'when no user stripe_id' do
      let(:user) { create(:user) }

      it 'calls create' do
        expect(subject).to receive(:create)
        result
      end
    end

    context 'when user stripe_id' do
      let(:user) { create(:user, stripe_id: 'cus_1234') }

      it 'calls find' do
        expect(subject).to receive(:find)
        result
      end
    end
  end

  describe '#create_subscription' do
    subject { StripeService::CustomerFacade.find(id) }
    let(:result) { subject.create_subscription }

    context 'when inactive' do
      let(:id) { 'cus_AM1Mq73jKV1Ghq' }

      it 'creates a new Stripe::Subscription' do
        VCR.use_cassette('services/stripe_service/customer_facade/create_subscription') do
          expect(subject.inactive?).to be true
          result
          expect(subject.inactive?).to be false
        end
      end
    end

    context 'when active' do
      let(:id) { 'cus_APAdfK1YEMXFiX' }

      it 'raises an error' do
        VCR.use_cassette('services/stripe_service/customer_facade/create_subscription_with_active') do
          expect(subject.inactive?).to be false
          expect { result }.to raise_error(StandardError)
        end
      end
    end
  end

  describe '#customer' do
    let(:subject) { StripeService::CustomerFacade.find(id) }
    let(:result) { subject.customer }

    context 'when customer exists' do
      let(:id) { 'cus_AMuXPSWyyZ5yJB' }

      it 'returns a customer' do
        VCR.use_cassette('stripe/retrieve_valid_customer') do
          expect(result).to be_a Stripe::Customer
        end
      end
    end

    context 'when customer does not exist' do
      let(:id) { 'cus_1234' }

      it 'raises Stripe::InvalidRequestError' do
        VCR.use_cassette('stripe/retrieve_invalid_customer') do
          expect { result }.to raise_error(Stripe::InvalidRequestError)
        end
      end
    end
  end

  describe '#source' do
    xit 'does something'
  end

  describe '#subscription' do
    let(:subject) { StripeService::CustomerFacade.find(id) }
    let(:result) { subject.subscription }

    context 'when customer exists' do
      context 'when subscription exists' do
        let(:id) { 'cus_AM1SRrH9GXWrnH' }

        it 'returns StripeService::SubscriptionFacade' do
          VCR.use_cassette('stripe/present_subscription') do
            expect(result).to be_a StripeService::SubscriptionFacade
          end
        end
      end

      context 'when subscription does not exist' do
        let(:id) { 'cus_ANHFVl6qffvqJ2' }

        it 'returns StripeService::SubscriptionFacade' do
          VCR.use_cassette('stripe/no_subscription') do
            expect(result).to be_a StripeService::SubscriptionFacade
          end
        end
      end
    end
  end

  describe '#update' do
    subject { StripeService::CustomerFacade.find(id) }
    let(:id) { 'cus_AIn5Geq031FzUD' }
    let(:result) { subject.update(email: new_email) }
    let(:old_email) { 'leonardo@marks.info' }
    let(:new_email) { 'mydumbtest@yogadose.xyz' }

    it 'updates Stripe::Customer' do
      VCR.use_cassette('services/stripe_service/customer_facade/update') do
        expect(subject.email).to eq old_email
        result
        expect(subject.email).to eq new_email
      end
    end
  end
end