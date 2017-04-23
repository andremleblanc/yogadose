require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #show' do
    describe 'unauthenticated access' do
      it 'redirects to login' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'authenticated access' do
      let(:subscriber) { create(:subscriber) }

      before do
        sign_in subscriber
        expect(subject).to receive(:current_user).twice.and_return(subscriber)
      end

      context 'when active subscriber' do
        before do
          expect(subscriber).to receive(:active?).and_return(true)
        end

        it 'returns http success' do
          VCR.use_cassette('controller/dashboard/get') { get :show }
          expect(response).to have_http_status(:success)
        end
      end

      context 'when non-active subscriber' do
        before do
          expect(subscriber).to receive(:active?).and_return(false)
        end

        it 'redirects to account path' do
          VCR.use_cassette('controller/dashboard/get') { get :show }
          expect(response).to redirect_to(subscription_path)
        end
      end
    end
  end
end
