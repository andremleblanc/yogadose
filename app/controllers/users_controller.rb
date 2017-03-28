class UsersController < ApplicationController
  def edit
    @user = User.find_by(id: params[:id]) || current_user
    authorize @user
  end

  def change_password
    @user = current_user
    render layout: 'devise', template: 'users/change_password'
  end

  def update_password
    if current_user.update(password_params)
      bypass_sign_in(current_user)
      flash[:success] = 'Successfully updated password.'
      redirect_to account_path
    else
      flash[:error] = current_user.errors.full_messages
      redirect_to change_password_path
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user_not_authorized
    #TODO: Metric / Log
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || dashboard_path)
  end
end
