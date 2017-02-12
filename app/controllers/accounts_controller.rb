class AccountsController < ApplicationController
  def show
    @user = User.find_by(id: params[:id]) || current_user
    authorize @user
  end
end