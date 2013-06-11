class UsersController < ApplicationController
  before_filter :find_venue, except: [:signup, :complete_signup]

  # Signup actions are used for /user/signup (new VenueOwner flow)
  def signup
    @user = User.new
  end

  def complete_signup
    @user = User.new params_for_venue_owner
    @user.roles = [:venue_owner]

    if @user.save
      cookies[:auth_token] = @user.auth_token
      redirect_to signup_venue_path
    else
      render :signup
    end
  end

  # Remaining actions are used only on venue/users routes

  def index
    @users = User.accessible_by current_ability
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new params_for_user
    role = params[:user][:role].to_sym
    @user.roles = role
    @user.venue_id = current_user.venue_id

    if @user.save
      redirect_to venue_users_path, notice: 'User created'
    else
      render :new
    end

  end

  private

  def find_venue
    @venue = current_user.venue
  end

  def params_for_venue_owner
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def params_for_user
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
