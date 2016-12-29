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
  end
end
