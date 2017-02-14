require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe '#facebook' do
    context 'unauthenticated' do
      context 'user persisted' do
        before do
          user = build(:user)
          expect(User).to receive(:from_omniauth).and_return user
          expect(user).to receive(:persisted?).and_return true
          @request.env['devise.mapping'] = Devise.mappings[:user]
        end

        it 'signs the user in and redirects to dashboard' do
          get :facebook
          expect(response).to redirect_to(new_subscription_path)
        end

        it 'displays flash' do
          get :facebook
          expect(flash[:notice]).to match /Facebook/
        end
      end

      context 'user not persisted' do
        before do
          user = build(:user)
          expect(User).to receive(:from_omniauth).and_return user
          expect(user).to receive(:persisted?).and_return false
          @request.env['devise.mapping'] = Devise.mappings[:user]
        end

        it 'redirects users to sign up' do
          get :facebook
          expect(response).to redirect_to(new_user_registration_path)
        end

        it 'displays flash' do
          get :facebook
          expect(flash[:error]).to eq I18n.t('flash.facebook_error')
        end
      end
    end

    context 'authenticated' do
      let(:subscriber) { create(:subscriber) }

      xit 'updates current user with facebook provider and uid' do
        sign_in(subscriber)
        get :facebook
      end
    end
  end

  describe 'email already exists' do
    pending 'figure out how to handle a connection that references an existing account from different user'
    # If no provider, then add provider
    # If existing provider, replace
  end
end
