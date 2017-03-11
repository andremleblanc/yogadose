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

    describe '#next_charge' do
      let(:result) { subscription.next_charge }

      context 'when Stripe::Subscription exists' do
        let(:time) { Time.now }

        before do
          expect(subscription).to receive(:stripe_subscription).at_least(1).and_return(stripe_subscription)
        end

        it 'is memoized' do
          expect(stripe_subscription).to receive(:current_period_end).and_return(time.to_i)
          expect(subscription).to receive(:status).and_return('trailing')
          subscription.next_charge
          subscription.next_charge
        end

        it 'is equal to the beginning of day following end of period' do
          expect(stripe_subscription).to receive(:current_period_end).and_return(time.to_i)
          expect(subscription).to receive(:status).and_return('trailing')
          expect(result).to eq time.advance(days: 1).beginning_of_day
        end

        it 'is nil if subscription is cancelling' do
          expect(subscription).to receive(:status).and_return(Subscription::CANCELLED)
          expect(result).to be_nil
        end
      end

      context 'when Stripe::Subscription does not exist' do
        it 'returns nil' do
          expect(subscription).to receive(:stripe_subscription)
          expect(result).to be_nil
        end
      end
    end

    describe '#status' do
      let(:result) { subscription.status }

      before do
        allow(stripe_subscription).to receive(:status).and_return('foo')
      end

      context 'when Stripe::Subscription exists' do
        before do
          expect(subscription).to receive(:stripe_subscription).at_least(1).and_return(stripe_subscription)
        end

        context 'and not cancelled' do
          it 'returns Stripe::Subscription status' do
            expect(stripe_subscription).to receive(:canceled_at)
            expect(result).to eq 'foo'
          end
        end

        context 'but is cancelled' do
          it 'returns Subscription::CANCELLING' do
            expect(stripe_subscription).to receive(:canceled_at).and_return(Time.now.to_i)
            expect(result).to eq Subscription::CANCELLING
          end
        end
      end

      context 'when Stripe::Subscription does not exist' do
        it 'returns Subscription::CANCELLED' do
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
