require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has one subscription' do
      subscriber = create(:subscriber)
      expect(subscriber.create_subscription(attributes_for :subscription)).to be_a Subscription
    end

    it 'has one payment_method' do
      subscriber = create(:subscriber)
      expect(subscriber.create_payment_method(attributes_for :payment_method)).to be_a PaymentMethod
    end
  end

  describe 'default values' do
    context 'admin' do
      context 'when nil' do
        it 'is set to false' do
          user = build(:user, admin: nil)
          user.valid?
          expect(user.admin).to be false
        end
      end

      context 'when not nil' do
        it 'is set to provided value' do
          provided_value = Faker::Boolean.boolean
          user = build(:user, admin: provided_value)
          user.valid?
          expect(user.admin).to be provided_value
        end
      end
    end
  end

  describe 'validations' do
    context 'name' do
      it 'is required' do
        user = build(:user, name: '')
        expect(user.valid?).to be false
      end
    end

    context 'password' do
      it 'has to be >= 8' do
        user = build(:user, password: '1234567')
        expect(user.valid?).to be false
        expect(user.errors[:password].first).to match /minimum is 8/
      end
    end
  end

  describe '#active?' do
    xit 'is true' do
      user = create(:user)
      expect(user.active?).to be true
    end
  end
end
