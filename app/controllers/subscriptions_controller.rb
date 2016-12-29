class SubscriptionsController < ApplicationController
  def new
  end

  def create
    if current_user.subscription.blank?
      if current_user.create_subscription(subscription_params).valid?
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
  end

  private

  def subscription_params
    params.require(:subscription).permit(:token)
  end
end
