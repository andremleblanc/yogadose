require 'rails_helper'

RSpec.feature 'Subscription', type: :feature, js: true do
  before do
    Sidekiq::Testing.inline!
  end

  after do
    Sidekiq::Testing.fake!
  end

  let(:user) { User.find_by(email: @email) }

  it 'Allows create, edit, and delete from account page' do
    sign_in

    # Account Page
    visit account_path
    expect(page).to have_current_path(account_path)
    click_on(I18n.t('accounts.show.sign_up'))
    expect(page).to have_current_path(new_subscription_path)

    # Create
    within_frame('stripeField_card_element0') do
      fill_in 'cardnumber', with: '4000000000000077'
      fill_in 'exp-date', with: '2' + Time.now.advance(years: 1).strftime('%y')
      fill_in 'cvc', with: Faker::Number.number(3)
      fill_in 'postal', with: Faker::Number.number(5)
    end
    click_on I18n.t('subscriptions.new.add_payment_method')

    # Account Page
    expect(page).to have_current_path(account_path)
    expect(user.payment_method).to be
    within('.subscription') { click_on I18n.t('accounts.show.update') }

    # Update
    expect(page).to have_current_path(edit_subscription_path)
    within_frame('stripeField_card_element0') do
      fill_in 'cardnumber', with: '4000000000000077'
      fill_in 'exp-date', with: '2' + Time.now.advance(years: 1).strftime('%y')
      fill_in 'cvc', with: Faker::Number.number(3)
      fill_in 'postal', with: Faker::Number.number(5)
    end
    click_on I18n.t('subscriptions.edit.update_payment_method')

    # Account Page
    expect(page).to have_current_path(account_path)
    expect(user.payment_method.last_four).to be '4078'
    within('.subscription') { click_on I18n.t('accounts.show.update') }

  end
end
