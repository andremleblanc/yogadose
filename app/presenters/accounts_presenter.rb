class AccountsPresenter
  def initialize(user)
    @user = user
  end

  def email
    @user.email
  end

  def name
    @user.name
  end

  def next_charge
    subscription.next_charge ? subscription.next_charge.strftime('%m/%e/%y') : 'No Pending Charge'
  end

  def payment_method?
    payment_method.present?
  end

  def payment_method_summary
    payment_method ? card_string : 'None'
  end

  def subscription
    @subscription ||= @user.subscription
  end

  def active_subscription?
    [ Subscription::CANCELLED, Subscription::CANCELLING ].exclude? subscription.status
  end

  def status
    subscription.status.titleize
  end

  def status_label
    case subscription.status
      when Subscription::CANCELLED
        'label-danger'
      when Subscription::CANCELLING
        'label-warning'
      else
        'label-primary'
    end
  end

  def subscription_path
    subscription ? edit_subscription_path(subscription) : new_subscription_path
  end

  private

  def brand
    payment_method.brand
  end

  def card_string
    "#{brand}: **** **** **** #{last_four}"
  end

  def last_four
    payment_method.last4
  end

  def payment_method
    @user.default_source
  end
end