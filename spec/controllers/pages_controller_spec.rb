require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  %w(home).each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, params: { id: page }
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(page) }
    end
  end
end
