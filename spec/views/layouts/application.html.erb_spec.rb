require 'rails_helper'

RSpec.describe 'layouts/application', type: :view do
  describe 'avatar' do
    context 'when user has image' do
      before do
        @user = create(:user, :with_image)
        sign_in @user
      end

      it 'shows image' do
        render
        expect(rendered).to match /User Profile Image/
      end
    end

    context 'when user has no image' do
      before do
        @user = create(:user)
        sign_in @user
      end

      it 'shows image' do
        render
        expect(rendered).not_to match /User Profile Image/
      end
    end
  end
end
