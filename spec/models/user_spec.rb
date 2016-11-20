require 'rails_helper'

RSpec.describe User, type: :model do
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
end
