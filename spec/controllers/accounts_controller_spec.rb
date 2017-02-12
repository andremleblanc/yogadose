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
      let(:admin) { create(:admin) }

      context 'accessing another user' do
        let(:another_user) { create(:subscriber) }

        context 'as a subscriber' do
          it 'redirects to dashboard path' do
            sign_in(subscriber)
            get :show, params: { id: another_user.id }
            expect(response).to redirect_to(dashboard_path)
          end
        end

        context 'as an admin' do
          it 'renders account' do
            sign_in(admin)
            get :show, params: { id: another_user.id }
            expect(response).to render_template(:show)
          end
        end
      end

      context 'accessing self' do
        it 'renders account' do
          sign_in(subscriber)
          get :show
          expect(response).to render_template(:show)
        end
      end
    end
  end
end