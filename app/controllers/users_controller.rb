class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new params_for_user

    if @user.save
      cookies[:auth_token] = @user.auth_token
      redirect_to signup_venues_path
    else
      render :new
    end

  end

  private

  def params_for_user
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
