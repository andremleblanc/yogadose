class UsersController < ApplicationController
  def index
    puts "User: #{User.all}"
    @users = User.all
  end
end
