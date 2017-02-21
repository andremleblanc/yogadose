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

  def payment_method?
    payment_method
  end

  def payment_method_summary
    payment_method ? card_string : 'None'
  end

  def subscription_path
    subscription = @user.subscription
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
    payment_method.last_four
  end

  def payment_method
    @user.payment_method
  end
end