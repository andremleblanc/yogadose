require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      payment_method = create(:payment_method, user: user)
      expect(payment_method.user).to be user
    end
  end

  describe 'validations' do
    context 'stripe_token' do
      it 'is required' do
        payment_method = build(:payment_method, stripe_token: nil)
        expect(payment_method).not_to be_valid
      end
    end
  end

  describe '#brand' do
    it 'uses card info' do
      payment_method = create(:payment_method)
      card = double('Card')
      expect(payment_method).to receive(:card).and_return(card)
      expect(card).to receive(:brand)
      payment_method.brand
    end
  end

  describe '#card' do
    it 'is memoized' do
      payment_method = create(:payment_method)
      token = double('Stripe::Token')
      card = double('Card')
      expect(Stripe::Token).to receive(:retrieve).and_return(token)
      expect(token).to receive(:card).and_return(card).once
      payment_method.card
      payment_method.card
    end
  end

  describe '#last_four' do
    it 'uses card info' do
      payment_method = create(:payment_method)
      card = double('Card')
      expect(payment_method).to receive(:card).and_return(card)
      expect(card).to receive(:last4)
      payment_method.last_four
    end
  end
end
