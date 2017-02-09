require 'rails_helper'

RSpec.feature 'Authentication', type: :feature, js: true do
  before do
    Sidekiq::Testing.inline!
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:facebook, {
        uid: '12345',
        info: { email: email, name: name }
    })
  end

  after do
    Sidekiq::Testing.fake!
  end

  let(:email) { Faker::Internet.email }
  let(:name) { Faker::Name.name }
  let(:password) { Faker::Internet.password(8) }

  xit 'Sign up with email, connect facebook, signout, login with facebook' do
    visit root_path
    click_on I18n.t('pages.home.sign_up')
    expect(page).to have_current_path(new_user_registration_path)

    fill_in I18n.t('devise.registrations.new.name'), with: name
    fill_in I18n.t('devise.registrations.new.email'), with: email
    fill_in I18n.t('devise.registrations.new.password'), with: password
    fill_in I18n.t('devise.registrations.new.password_confirmation'), with: password
    click_on 'Sign Up'

    expect(page).to have_current_path(new_subscription_path)
    #TODO: expect(page).not_to have_content(I18n.t('devise.registrations.signed_up'))
    expect(page).to have_content(name)

    fill_in 'card-number', with: '4000000000000077'
    fill_in 'exp-month', with: Time.now.strftime('%m')
    fill_in 'exp-year', with: Time.now.advance(years: 1).strftime('%y')
    fill_in 'cvc', with: Faker::Number.number(3)
    fill_in 'zipcode', with: Faker::Number.number(5)
    click_on I18n.t('subscriptions.new.subscribe')

    expect(page).to have_current_path(account_path)
    expect(User.find_by(email: email).payment_method).to be
  end

  it 'Sign up with facebook, setup credentials, logout, login with credentials' do
    # Sign Up and Login
    visit new_user_session_path
    click_on I18n.t('devise.sessions.new.facebook_authentication')
    expect(page).to have_current_path(dashboard_path)

    # Set Password
    click_on name
    click_on I18n.t('account_settings')
    expect(page).to have_current_path(account_path)

    # Logout
    click_on name
    click_on I18n.t('logout')
    expect(page).to have_current_path('/temp.html')

    # Login
    visit new_user_session_path
    fill_in I18n.t('devise.registrations.new.email'), with: email
    fill_in I18n.t('devise.registrations.new.password'), with: password
    click_on I18n.t('devise.sessions.new.login')
    expect(page).to have_current_path(dashboard_path)
  end
end
