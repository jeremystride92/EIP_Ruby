class SessionsController < ApplicationController
  skip_authorization_check

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end

      url = if user.has_any_role? :venue_owner, :venue_manager
              venue_url
            else
              root_url
            end

      redirect_to url, notice: 'You are now logged in'
    else
      flash.now[:alert] = 'Email or password invalid'
      render :new
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, notice: 'You are now logged out'
  end
end
