class UsersController < ApplicationController
  def index
    authorize(User)
    @users = policy_scope(User)
  end

  def edit
    @user = User.find_by(id: params[:id]) || current_user
    authorize @user
  end

  private

  def user_not_authorized
    #TODO: Track this
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || dashboard_path)
  end
end
