require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context '#index' do
    context 'unauthenticated' do
      before do
        @user = create(:user)
        get :index
      end

      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'authenticated' do
      before do
        @user = create(:user)
        sign_in(@user)
        get :index
      end

      it { expect(response).to render_template(:index) }
      it { expect(assigns(:users)).to eq([@user]) }
    end
  end
end
