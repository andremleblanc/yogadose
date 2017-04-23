require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context 'GET change_password' do
    context 'unauthenticated' do
      it 'redirects to new user session path' do
        get :change_password
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authenticated' do
      let(:user) { create(:subscriber) }

      before do
        sign_in_active_user
      end

      context 'subscriber editing self' do
        it 'renders' do
          get :change_password
          expect(response).to render_template('change_password')
        end
      end
    end
  end

  context 'PUT update_password' do
    context 'unauthenticated' do
      it 'redirects to new user session path' do
        put :update_password
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'authenticated' do
      let(:user) { create(:subscriber) }

      before do
        sign_in_active_user
      end

      context 'subscriber editing self' do
        context 'invalid params' do
          it 'renders form again' do
            put :update_password, params: {user: {password: 'abc', password_confirmation: 'abc'}}
            expect(response).to redirect_to(change_password_path)
            expect(flash[:error]).to be
          end
        end

        context 'valid params' do
          it 'redirects to account settings' do
            put :update_password, params: {user: {password: 'abcd1234', password_confirmation: 'abcd1234'}}
            expect(response).to redirect_to(account_path)
            expect(flash[:success]).to match('Successfully updated password.')
          end
        end
      end
    end
  end
end
