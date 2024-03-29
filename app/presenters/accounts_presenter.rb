class AccountsPresenter
  def initialize(user)
    @user = user
  end

  def connected_to_facebook?
    @user.provider && @user.uid
  end

  def email
    @user.email
  end

  def name
    @user.name
  end

  def next_charge
    subscription.next_charge ? subscription.next_charge.strftime('%m/%d/%y') : 'No Pending Charge'
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
    subscription.active?
  end

  def cancelling_subscription?
    subscription.cancelling?
  end

  def status
    if subscription.cancelling?
      'Cancelling'
    else
      subscription.status.titleize
    end
  end

  def status_label
    if subscription.inactive?
      'label-danger'
    elsif subscription.cancelling?
      'label-warning'
    else
      'label-primary'
    end
  end

  def subscription_path
    subscription_path
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
    @user.source
  end
end