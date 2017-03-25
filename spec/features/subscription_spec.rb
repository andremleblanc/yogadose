require 'rails_helper'

RSpec.feature 'Subscription', type: :feature, js: true do
  let(:user) { User.find_by(email: @email) }
  let(:name) { user.name }
  let(:next_charge) { Time.now.advance(days: 8).strftime('%m/%d/%y') }

  it 'Allows create, edit, delete, and reactivate from account page' do
    sign_in

    # Account Page
    visit account_path
    expect(page).to have_current_path(account_path)
    expect(page).not_to have_text(next_charge)
    click_on(I18n.t('accounts.show.sign_up'))
    expect(page).to have_current_path(new_subscription_path)

    # Create
    within_frame 0 do
      fill_in 'cardnumber', with: '4000000000000077'
      fill_in 'exp-date', with: '2' + Time.now.advance(years: 1).strftime('%y')
      fill_in 'cvc', with: Faker::Number.number(3)
      fill_in 'postal', with: Faker::Number.number(5)
    end
    click_on I18n.t('subscriptions.new.submit_label')

    # Dashboard Page
    expect(page).to have_current_path(dashboard_path)
    click_on name
    click_on I18n.t('account_settings')

    # Account Page
    expect(page).to have_current_path(account_path)
    expect(page).to have_text(next_charge)
    expect(user.default_source).to be
    within('.subscription') { click_on I18n.t('accounts.show.update') }

    # Update
    expect(page).to have_current_path(edit_subscription_path)
    within_frame 0 do
      fill_in 'cardnumber', with: '4242424242424242'
      fill_in 'exp-date', with: '2' + Time.now.advance(years: 1).strftime('%y')
      fill_in 'cvc', with: Faker::Number.number(3)
      fill_in 'postal', with: Faker::Number.number(5)
    end
    click_on I18n.t('subscriptions.edit.submit_label')

    # Account Page
    expect(page).to have_current_path(account_path)
    expect(page).to have_text '4242'
    expect(page).to have_text(next_charge)

    # Delete
    within('.subscription') { click_on 'Cancel' }
    page.accept_alert
    expect(page).to have_current_path(account_path)
    expect(page).to have_text 'Reactivate Your Subscription'
    expect(page).to have_css('.subscription .label', text: 'Cancelling')
    expect(page).to have_text('No Pending Charge')

    # Reactivate
    click_on 'Reactivate'
    expect(page).to have_current_path(account_path)
    expect(page).to have_text(I18n.t('flash.subscription_reactivated'))
  end
end
