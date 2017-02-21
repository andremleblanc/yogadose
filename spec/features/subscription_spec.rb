require 'rails_helper'

RSpec.feature 'Subscription', type: :feature do
  before do
    Sidekiq::Testing.inline!
  end

  after do
    Sidekiq::Testing.fake!
  end

  let(:user) { create(:user) }

  it 'Allows create, edit, and delete from account page' do
    sign_in(user)
    visit account_path
    expect(page).to have_current_path(account_path)
    expect(true).to be false
  end
end
