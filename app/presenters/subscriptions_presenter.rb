class SubscriptionsPresenter
  include Rails.application.routes.url_helpers

  def initialize(user = nil)
    @user = user
  end

  def submit_label
    @user.active? ? I18n.t('subscriptions.edit.submit_label') : I18n.t('subscriptions.new.submit_label')
  end

  def submit_method
    @user.active? ? :patch : :post
  end

  def submit_path
    @user.active? ? update_subscription_path : subscriptions_path
  end
end