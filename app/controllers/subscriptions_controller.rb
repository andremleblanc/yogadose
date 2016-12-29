class SubscriptionsController < ApplicationController
  def new
  end

  def create
    if current_user.subscription.blank?
      if stripe_token.present? && current_user.create_subscription
        current_user.create_payment_method!(token: stripe_token)
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

  def stripe_token
    params[:token]
  end

  def subscription_params
    params.require(:subscription).permit()
  end
end
