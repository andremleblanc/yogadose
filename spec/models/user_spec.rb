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

  describe '#active?' do
    xit 'is true' do
      user = create(:user)
      expect(user.active?).to be true
    end
  end
end
