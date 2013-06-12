class UsersController < ApplicationController
  layout 'venue', except: [:signup, :complete_signup, :reset_password_form, :reset_password]

  before_filter :find_venue, except: [:signup, :complete_signup, :reset_password, :reset_password_form]
  before_filter :find_user_by_token, only: [:reset_password, :reset_password_form]

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

  # Reset password actions
  def reset_password_form
  end

  def reset_password
    @user.assign_attributes(params_for_reset)
    @user.password ||= ''
    if @user.save
      @user.update_attributes(reset_token: nil, reset_token_date: nil)
      redirect_to login_path, notice: 'Password set'
    else
      render :reset_password_form
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
    role = params[:user][:roles].to_sym
    @user.roles = [role]
    @user.venue_id = current_user.venue_id
    @user.generate_unusable_password!
    @user.send_activation_email

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

  def find_user_by_token
    @user = User.find_by_reset_token!(params[:reset_token])
    redirect_to :token_expired if @user.reset_token_date < 1.day.ago
  end

  def params_for_venue_owner
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def params_for_user
    params.require(:user).permit(:email)
  end

  def params_for_reset
    params.require(:user).permit(:password, :password_confirmation)
  end
end
