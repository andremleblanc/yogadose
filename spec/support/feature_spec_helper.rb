module FeatureSpecHelper
  def self.included(base)
    base.before do
      @name = Faker::Name.name
      @email = Faker::Internet.email
      @password = Faker::Internet.password(8)
    end
  end

  def sign_in
    # Login
    visit new_user_session_path
    click_link I18n.t('devise.shared.links.sign_up')

    # Sign Up Page
    fill_in I18n.t('devise.registrations.new.name'), with: @name
    fill_in I18n.t('devise.registrations.new.email'), with: @email
    fill_in I18n.t('devise.registrations.new.password'), with: @password
    fill_in I18n.t('devise.registrations.new.password_confirmation'), with: @password
    click_on 'Sign Up'
  end
end
