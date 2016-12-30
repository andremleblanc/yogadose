class SubscriptionsController < ApplicationController
  def new
    render current_user.subscription.blank? ? :new : :edit
  end

  def create
    if current_user.subscription.blank?
      if stripe_token.present? && create_subscription
        SubscriptionWorker.perform_async(current_user.id, stripe_token)
        flash[:success] = I18n.t('flash.subscription_success')
        redirect_to account_path
      else
        flash[:error] = I18n.t('flash.subscription_error')
        render :new
      end
    else
      flash[:notice] = I18n.t('flash.subscription_already_exists')
      render :edit
    end
  end

  def edit
    @subscription = Subscription.find(params[:id])
    authorize @subscription
  end

  private

  def create_subscription
    current_user.create_subscription
  end

  def stripe_token
    params[:token]
  end

  def subscription_params
    params.require(:subscription).permit()
  end
end
