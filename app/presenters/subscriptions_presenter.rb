class SubscriptionsPresenter
  def initialize(subscription = nil)
    @subscription = subscription
  end

  def submit_label
    @subscription ? I18n.t('subscriptions.edit.submit_label') : I18n.t('subscriptions.new.submit_label')
  end
end