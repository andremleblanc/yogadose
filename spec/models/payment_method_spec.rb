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
end
