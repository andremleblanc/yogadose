require 'rails_helper'

RSpec.describe 'Root path', type: :request do
  context 'when logged in' do
    it 'renders dashboard' do
      user = create(:user)
      sign_in user
      get root_path
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