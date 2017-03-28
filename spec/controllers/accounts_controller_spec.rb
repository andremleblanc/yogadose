require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  describe 'GET #show' do
    context 'unauthenticated' do
      it 'redirects to dashboard path' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'authenticated' do
      let(:subscriber) { create(:subscriber) }

      context 'accessing another user' do
        let(:another_user) { create(:subscriber) }
        let(:user) { subscriber }

        it "renders subscriber's account" do
          sign_in_active_user
          expect(AccountsPresenter).to receive(:new).with(user)
          get :show, params: { id: another_user.id }
          expect(response).to render_template(:show)
        end
      end

      context 'accessing self' do
        let(:user) { subscriber }

        it 'renders account' do
          sign_in_active_user
          expect(AccountsPresenter).to receive(:new).with(user)
          get :show
          expect(response).to render_template(:show)
        end
      end
    end
  end
end