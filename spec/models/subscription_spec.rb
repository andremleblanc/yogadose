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
end
