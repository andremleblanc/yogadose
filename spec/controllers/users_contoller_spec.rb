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
end
