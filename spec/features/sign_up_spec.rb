require 'rails_helper'

RSpec.feature 'Registration', type: :feature, js: true do
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
  end
end
