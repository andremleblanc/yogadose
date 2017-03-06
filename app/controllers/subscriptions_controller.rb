class SubscriptionsController < ApplicationController
  def new
    @presenter = SubscriptionsPresenter.new(current_user.subscription)
    render current_user.subscription.blank? ? :new : :edit
  end

  def create
    if current_user.subscription.blank?
      if stripe_token.present? && create_subscription
        SubscriptionWorker.perform_async(current_user.id, stripe_token)
        flash[:success] = I18n.t('flash.subscription_success')
        redirect_to account_path
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
    subscription = current_user.subscription
    if stripe_token.present?
      flash[:success] = I18n.t('flash.subscription_updated')
      SubscriptionWorker.perform_async(current_user.id, stripe_token)
      redirect_to account_path
    else
      flash[:error] = I18n.t('flash.subscription_not_updated')
      redirect_to edit_subscription_path
    end
  end

  private

  def create_subscription
    current_user.create_subscription
  end

  def stripe_token
    params[:stripeToken]
  end

  def subscription_params
    params.require(:subscription).permit()
  end
end
