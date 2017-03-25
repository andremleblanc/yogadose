class SubscriptionsController < ApplicationController
  def new
    @presenter = SubscriptionsPresenter.new(current_user.subscription)
    render current_user.subscription.blank? ? :new : :edit
  end

  def create
    if current_user.subscription.blank?
      if stripe_token.present? && create_subscription
        activate_subscription
        flash[:success] = I18n.t('flash.subscription_success')
        redirect_to dashboard_path
      else
        # TODO: Record metric and log; improve error message
        flash[:error] = I18n.t('flash.subscription_error')
        redirect_to new_subscription_path
      end
    else
      flash[:notice] = I18n.t('flash.subscription_already_exists')
      redirect_to edit_subscription_path
    end
  end

  def edit
    subscription = Subscription.find_by(id: params[:id]) || current_user.subscription
    authorize subscription
    @presenter = SubscriptionsPresenter.new(subscription)
    render :edit
  end

  def update
    if stripe_token.present?
      flash[:success] = I18n.t('flash.subscription_updated')
      activate_subscription
      redirect_to account_path
    elsif reactivate_subscription
      flash[:success] = I18n.t('flash.subscription_reactivated')
      redirect_to account_path
    else
      flash[:error] = I18n.t('flash.subscription_not_updated')
      redirect_to edit_subscription_path
    end
  end

  def destroy
    cancel_subscription
    flash[:success] = I18n.t('flash.subscription.cancelled')
    redirect_to account_path
  end

  private

  def activate_subscription
    current_user.update_stripe(source: stripe_token, email: current_user.email)
    current_user.subscription.activate if current_user.subscription.inactive?
  end

  def cancel_subscription
    current_user.subscription.cancel_subscription
  end

  def create_subscription
    current_user.create_subscription
  end

  def reactivate_subscription
    current_user.subscription.activate
  end

  def stripe_token
    params[:stripeToken]
  end

  def subscription_params
    params.require(:subscription).permit()
  end
end
