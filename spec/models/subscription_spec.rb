require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      subscriber = create(:subscriber)
      subscription = create(:subscription, user: subscriber)
      expect(subscription.user).to be subscriber
    end
  end

  describe 'validations' do
    context 'token' do
      it 'is required' do
        subscription = build(:subscription, token: '')
        expect(subscription.valid?).to be false
      end
    end

    context 'user' do
      before do
        @subscriber = create(:subscriber)
        create(:subscription, user: @subscriber)
      end

      it 'is unique' do
        expect(@subscriber.subscription).to be_a Subscription
        expect(build(:subscription, user: @subscriber)).not_to be_valid
      end
    end
  end

  describe '#trial_expiry' do
    it 'is set to end of day 7 days from created_at' do
      subscription = create(:subscription)
      expect(subscription.trial_expiry).to eq subscription.created_at.advance(days: 7).end_of_day
    end
  end
end
