require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:user) { build(:user) }
  
  before do
    allow(subject).to receive(:current_user).and_return(nil, user)
    allow(user).to receive(:active?).and_return(false)
    expect(User).to receive(:from_omniauth).and_return user
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#facebook' do
    context 'unauthenticated' do
      context 'user persisted' do
        before do
          expect(user).to receive(:persisted?).and_return true
        end

        it 'signs the user in and redirects to dashboard' do
          get :facebook
          expect(response).to redirect_to(subscription_path)
        end

        it 'displays flash' do
          get :facebook
          expect(flash[:notice]).to match /Facebook/
        end
      end

      context 'user not persisted' do
        before do
          expect(user).to receive(:persisted?).and_return false
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
  end
end
