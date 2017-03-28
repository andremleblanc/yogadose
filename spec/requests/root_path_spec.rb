require 'rails_helper'

RSpec.describe 'Root path', type: :request do
  context 'when logged in' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      expect(user).to receive(:active?).and_return(true)
    end

    it 'renders dashboard' do
      VCR.use_cassette('requests/root/get') { get root_path }
      expect(response).to render_template(:show)
    end
  end

  context 'when not logged in' do
    it 'redirects to home page' do
      get root_path
      expect(response).to redirect_to('/welcome.html')
    end
  end
end