require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      subscriber = create(:user)
      subscription = create(:subscription, user: subscriber)
      expect(subscription.user).to be subscriber
    end
  end

  describe 'validations' do
    context 'user' do
      before do
        @subscriber = create(:subscriber)
      end

      it 'is unique' do
        expect(@subscriber.subscription).to be_a Subscription
        expect(build(:subscription, user: @subscriber)).not_to be_valid
      end
    end
  end

  describe 'InstanceMethods' do
    let(:subscription) { create(:subscription) }
    let(:stripe_subscription) { double('Stripe::Subscription') }

    describe '#active?' do
      let(:result) { subscription.active? }

      context 'when subscription is active' do
        it 'returns true' do
          expect(subscription).to receive(:stripe_subscription).at_least(1).and_return(stripe_subscription)
          expect(result).to be true
        end
      end

      context 'when subsctiption is cancelled' do
        it 'returns false' do
          expect(subscription).to receive(:stripe_subscription)
          expect(result).to be false
        end
      end
    end

    describe '#cancel_subscription' do
      let(:result) { subscription.cancel_subscription }

      context 'when subscription is active' do
        it 'calls delete on Stripe::Subscription' do
          expect(subscription).to receive(:stripe_subscription).at_least(1).and_return(stripe_subscription)
          expect(stripe_subscription).to receive(:delete)
          result
        end
      end

      context 'when subscription is cancelled' do
        it 'does nothing' do
          expect(subscription).to receive(:stripe_subscription)
          result
        end
      end
    end

    describe '#status' do
      let(:result) { subscription.status }

      context 'when subscription is active' do
        it 'calls status on Stripe::Subscription' do
          expect(subscription).to receive(:stripe_subscription).at_least(1).and_return(stripe_subscription)
          expect(stripe_subscription).to receive(:status)
          result
        end
      end

      context 'when subscription is cancelled' do
        it 'returns cancelled' do
          expect(subscription).to receive(:stripe_subscription)
          expect(result).to eq Subscription::CANCELLED
        end
      end
    end

    describe '#stripe_subscription' do
      context 'when subscription is active' do
        it 'retrieves and memoizes subscription from stripe' do
          expect(Stripe::Subscription).to receive(:retrieve).with(subscription.stripe_id).and_return(Object.new)
          subscription.stripe_subscription
          subscription.stripe_subscription
        end
      end

      context 'when subscription is cancelled' do
        it 'retrieves and memoizes nil' do
          expect(Stripe::Subscription).to receive(:retrieve).with(subscription.stripe_id).and_raise(Stripe::InvalidRequestError.new('blah', 'blah'))
          subscription.stripe_subscription
          subscription.stripe_subscription
        end
      end
    end

    describe '#trial_expiry' do
      it 'is set to end of day 7 days from created_at' do
        expect(subscription.trial_expiry).to eq subscription.created_at.advance(days: 7).end_of_day
      end
    end
  end
end
