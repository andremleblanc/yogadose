class AccountsController < ApplicationController
  def show
    @presenter = AccountsPresenter.new(current_user)
  end
end