require 'rails_helper'

RSpec.feature 'Authentication', type: :feature, js: true do
  before do
    Sidekiq::Testing.inline!
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:facebook, {
        uid: Faker::Number.number(5),
        info: { email: email, name: name }
    })
  end

  after do
    Sidekiq::Testing.fake!
  end

  let(:email) { Faker::Internet.email }
  let(:alt_email) { Faker::Internet.email }
  let(:name) { Faker::Name.name }
  let(:password) { Faker::Internet.password(8) }
  let(:new_password) { Faker::Internet.password(8) }

  it 'Sign up with email, connect facebook, logout, login with facebook' do
    visit new_user_session_path
    click_link I18n.t('devise.shared.links.sign_up')

    # Sign Up
    fill_in I18n.t('devise.registrations.new.name'), with: name
    fill_in I18n.t('devise.registrations.new.email'), with: alt_email
    fill_in I18n.t('devise.registrations.new.password'), with: password
    fill_in I18n.t('devise.registrations.new.password_confirmation'), with: password
    click_on 'Sign Up'
    expect(page).to have_current_path(new_subscription_path)

    # Subscription Settings
    within_frame('stripeField_card_element0') do
      fill_in 'cardnumber', with: '4000000000000077'
      fill_in 'exp-date', with: '2' + Time.now.advance(years: 1).strftime('%y')
      fill_in 'cvc', with: Faker::Number.number(3)
      fill_in 'postal', with: Faker::Number.number(5)
    end
    click_on I18n.t('subscriptions.payment_info.subscribe')

    expect(page).to have_current_path(account_path)
    expect(User.find_by(email: alt_email).payment_method).to be

    # Go to Account Settings
    click_on name
    click_on I18n.t('account_settings')
    expect(page).to have_current_path(account_path)

    # Connect account
    click_link 'connect-facebook-account'
    expect(page).to have_current_path(account_path)
    expect(page).to have_content('Successfully connected Facebook account.')

    # Logout
    click_on name
    click_on I18n.t('logout')
    expect(page).to have_current_path(new_user_session_path)

    # Login
    expect_any_instance_of(User).to receive(:active?).and_return(true) #TODO: remove this stub
    click_on I18n.t('devise.sessions.new.facebook_authentication')
    expect(page).to have_current_path(dashboard_path)
  end

  it 'Sign up with facebook, setup credentials, logout, login with credentials' do
    # Sign Up and Login
    visit new_user_session_path
    click_on I18n.t('devise.sessions.new.facebook_authentication')
    expect(page).to have_current_path(new_subscription_path)

    # Subscription Settings
    within_frame('stripeField_card_element0') do
      fill_in 'cardnumber', with: '4000000000000077'
      fill_in 'exp-date', with: '2' + Time.now.advance(years: 1).strftime('%y')
      fill_in 'cvc', with: Faker::Number.number(3)
      fill_in 'postal', with: Faker::Number.number(5)
    end
    click_on I18n.t('subscriptions.payment_info.subscribe')

    expect(page).to have_current_path(account_path)
    expect(User.find_by(email: email).payment_method).to be

    # Go to Account Settings
    click_on name
    click_on I18n.t('account_settings')
    expect(page).to have_current_path(account_path)

    # Go to change password page
    click_link 'change-password'
    expect(page).to have_current_path(change_password_path)

    # Change password
    fill_in 'New Password', with: new_password
    fill_in 'Password Again', with: new_password
    click_on 'Change Password'
    expect(page).to have_current_path(account_path)

    # Logout
    click_on name
    click_on I18n.t('logout')
    expect(page).to have_current_path(new_user_session_path)

    # Login
    expect_any_instance_of(User).to receive(:active?).and_return(true) #TODO: remove this stub
    visit new_user_session_path
    fill_in I18n.t('devise.registrations.new.email'), with: email
    fill_in I18n.t('devise.registrations.new.password'), with: new_password
    click_on I18n.t('devise.sessions.new.login')
    expect(page).to have_current_path(dashboard_path)
  end
end
