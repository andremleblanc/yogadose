class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_active
  
  def facebook
    auth = request.env['omniauth.auth']

    if current_user
      @user = current_user
      if @user.update(provider: auth.provider, uid: auth.uid)
        flash[:notice] = 'Successfully connected Facebook account.'
      else
        #TODO: Metric / Log
        flash[:error] = 'Was not able to connect Facebook account.'
      end
      redirect_to account_path
    else
      @user = User.from_omniauth(auth)
      if @user.persisted?
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
        sign_in_and_redirect @user, event: :authentication
      else
        #TODO: Metric / Log
        flash[:error] = I18n.t('flash.facebook_error')
        redirect_to new_user_registration_url
      end
    end
  end

  def failure
    redirect_to root_path
  end
end
