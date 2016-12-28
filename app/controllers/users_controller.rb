class UsersController < ApplicationController
  def index
    if UserPolicy.new(current_user, User).index?
      @users = policy_scope(User)
    else
      redirect_to dashboard_path
    end
  end
end
