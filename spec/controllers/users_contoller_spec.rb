require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context 'GET index' do
    context 'unauthenticated' do
      before do
        @user = create(:subscriber)
        get :index
      end

      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'authenticated' do
      context 'authorized' do
        before do
          @user = create(:admin)
          sign_in(@user)
          get :index
        end

        it { expect(response).to render_template(:index) }
        it { expect(assigns(:users)).to eq([@user]) }
      end

      context 'unauthorized' do
        before do
          @user = create(:subscriber)
          sign_in(@user)
          get :index
        end

        it { expect(response).to redirect_to dashboard_path }
      end
    end
  end

  context 'GET edit' do
    before do
      @user = create(:subscriber)
    end

    context 'unauthenticated' do
      it 'redirects to login' do
        get :edit
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'authenticated' do
      before do
        sign_in(@user)
      end

      context 'when id provided' do
        context 'authorized' do
          it 'renders edit' do
            get :edit, params: { id: @user.id }
            expect(response).to render_template(:edit)
          end
        end

        context 'unauthorized' do
          let(:another_user) { create(:subscriber) }

          it 'redirects to dashboard' do
            get :edit, params: { id: another_user.id }
            expect(response).to redirect_to dashboard_path
          end
        end
      end

      context 'when id not provided' do
        it 'sets the user to current_user' do
          get :edit
          expect(assigns(:user)).to eq(@user)
        end

        it 'is authorized' do
          get :edit
          expect(response).to render_template(:edit)
        end
      end
    end
  end
end
