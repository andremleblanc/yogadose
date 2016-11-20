require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'unauthenticated access' do
    it 'returns http redirect' do
      get :show
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'authenticated access' do
    before do
      @user = create(:user)
      sign_in @user
    end

    describe 'GET #show' do
      it 'returns http success' do
        get :show
        expect(response).to have_http_status(:success)
      end
    end
  end
end
