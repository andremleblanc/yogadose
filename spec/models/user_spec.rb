require 'rails_helper'

RSpec.describe User, type: :model do
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

  describe 'instance methods' do
    let(:user) { create(:user) }

    describe '#active?' do
      let(:subject) { user }
      let(:result) { subject.active? }

      it 'delegates to subscription' do
        customer_facade = double('StripeService::CustomerFacade')
        expect(subject).to receive(:customer_facade).and_return(customer_facade)
        expect(customer_facade).to receive(:active?)
        result
      end
    end

    describe '#create_subscription' do
      let(:subject) { user }
      let(:result) { subject.create_subscription(token) }
      let(:customer_facade) { double('StripeService::CustomerFacade') }
      let(:token) { 'tok_1234' }

      it 'creates subscription' do
        expect(subject).to receive(:customer_facade).twice.and_return(customer_facade)
        expect(customer_facade).to receive(:update).with(source: token)
        expect(customer_facade).to receive(:create_subscription)
        result
      end
    end

    describe '#inactive?' do
      let(:subject) { user }
      let(:result) { subject.inactive? }

      it 'delegates to subscription' do
        customer_facade = double('StripeService::CustomerFacade')
        expect(subject).to receive(:customer_facade).and_return(customer_facade)
        expect(customer_facade).to receive(:inactive?)
        result
      end
    end

    describe '#update_subscription' do
      xit 'does something'
    end
  end
end
