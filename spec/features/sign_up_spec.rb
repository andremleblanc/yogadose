require 'rails_helper'

RSpec.feature 'Signing up', type: :feature, js: true do
  let(:email) { Faker::Internet.email }
  let(:name) { Faker::Name.name }
  let(:password) { Faker::Internet.password(8) }

  scenario 'Sign up' do
    visit root_path
    click_on I18n.t('pages.home.sign_up')
    expect(page).to have_current_path(new_user_registration_path)

    fill_in I18n.t('devise.registrations.new.name'), with: name
    fill_in I18n.t('devise.registrations.new.email'), with: email
    fill_in I18n.t('devise.registrations.new.password'), with: password
    fill_in I18n.t('devise.registrations.new.password_confirmation'), with: password
    click_on 'Sign Up'

    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
    expect(page).to have_content(name)
  end
end
