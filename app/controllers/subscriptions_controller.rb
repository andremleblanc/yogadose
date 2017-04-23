class SubscriptionsController < ApplicationController
  skip_before_action :verify_active

  def create
    if current_user.inactive?
      if stripe_token.present?
        current_user.create_subscription(stripe_token)
        flash[:success] = I18n.t('flash.subscription_success')
        redirect_to dashboard_path
      else
        #TODO: Metric / Log
        flash[:error] = I18n.t('flash.subscription_error')
        redirect_to subscription_path
      end
    else
      flash[:notice] = I18n.t('flash.subscription_already_exists')
      redirect_to subscription_path
    end
  end

  def edit
    @presenter = SubscriptionsPresenter.new(current_user)
  end

  def reactivate
    user = current_user
    if user.cancelling?
      user.reactivate
      flash[:success] = I18n.t('subscriptions.reactivate.success')
      redirect_back fallback_location: account_url
    else
      flash[:error] = I18n.t('subscriptions.reactivate.already_active')
      redirect_back fallback_location: account_url
    end
  end

  def update
    if subscription_params.present?
      current_user.update_subscription(subscription_params)
      flash[:success] = I18n.t('flash.subscription_updated')
      redirect_to account_path
    else
      #TODO: Metric / Log
      flash[:error] = 'Invalid Values'
      redirect_back fallback_location: account_url
    end
  end

  def destroy
    current_user.cancel_subscription
    flash[:success] = I18n.t('flash.subscription.cancelled')
    redirect_to account_path
  end

  private

  def stripe_token
    params[:stripeToken]
  end

  def subscription_params
    {stripe_token: stripe_token}.compact
  end
end
