require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has one subscription' do
      subscriber = create(:user)
      expect(subscriber.create_subscription(attributes_for :subscription)).to be_a Subscription
    end

    xit 'destroying a user keep subscription' do
      pending
      #subscriber
      #subscriber.destory
      #user.create(subscriber.email).subscription == subscriber.subscription
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

  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:stripe_customer) { double('Stripe::Customer') }

    # describe '#default_source' do
    #   context 'when user defined in Stripe' do
    #     before do
    #       VCR.use_cassette('users/link_to_stripe') do
    #         user.link_to_stripe
    #       end
    #
    #       VCR.use_cassette('users/get_token') do
    #         token = Stripe::Token.create(
    #             :card => {
    #                 :number => "4242424242424242",
    #                 :exp_month => 2,
    #                 :exp_year => 2018,
    #                 :cvc => "314"
    #             },
    #         )
    #       end
    #
    #       user.update_stripe(source: token)
    #     end
    #
    #     it 'returns the default source' do
    #       VCR.use_cassette('users/default_source') do
    #         expect(user.default_source).to be
    #       end
    #     end
    #   end
    #
    #   context 'when user not defined in Stripe' do
    #     it 'returns nil' do
    #       expect(user.default_source).to be_nil
    #     end
    #   end
    # end

    describe '#update_stripe' do
      subject { user.update_stripe(email: 'mydumbtest@yogadose.xyz') }
      let(:customer_id) { 'cus_1234' }

      context 'when user defined in Stripe' do
        let(:user) { create(:user, stripe_id: customer_id) }

        it 'updates Stripe::Customer' do
          expect(Stripe::Customer).to receive(:retrieve).with(customer_id).and_return(stripe_customer)
          expect(stripe_customer).to receive(:email=)
          expect(stripe_customer).to receive(:save)

          expect(user.stripe_id).to eq customer_id
          subject
          expect(user.stripe_id).to eq customer_id
        end
      end

      context 'when user not defined in Stripe' do
        let(:user) { create(:user, stripe_id: nil) }

        it 'creates Stripe::Customer and updates' do
          expect(Stripe::Customer).to receive(:create).with(email: user.email).and_return(stripe_customer)
          expect(stripe_customer).to receive(:id).and_return(customer_id)
          expect(stripe_customer).to receive(:email=)
          expect(stripe_customer).to receive(:save)

          expect(user.stripe_id).to be_nil
          subject
          expect(user.stripe_id).to eq customer_id
        end
      end
    end
  end
end
