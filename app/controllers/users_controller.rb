class UsersController < ApplicationController
  SIGNUP_ACTIONS = [:signup, :complete_signup].freeze
  UNKNOWN_PASSWORD_ACTIONS = [:reset_password_form, :reset_password, :forgot_password, :send_password_reset].freeze
  PUBLIC_ACTIONS = (SIGNUP_ACTIONS + UNKNOWN_PASSWORD_ACTIONS).freeze

  public_actions *PUBLIC_ACTIONS

  before_filter :authenticate, except: PUBLIC_ACTIONS

  before_filter :find_venue, except: PUBLIC_ACTIONS
  before_filter :find_user_by_token, only: [:reset_password, :reset_password_form]

  # #index gets to skip auth since it uses accessible_by
  skip_authorization_check only: PUBLIC_ACTIONS + [:index]

  # Signup actions are used for /user/signup (new VenueOwner flow)
  def signup
    @user = User.new
  end

  def complete_signup
    @user = User.new params_for_venue_owner
    @user.roles = [:venue_owner]

    authorize! :create, @user

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

  # Forgotten password actions
  def forgot_password
  end

  def send_password_reset
    @email = params[:email]
    @user = User.find_by_email(@email)
    @user.send_password_reset_email! if @user
    @user = nil # security measure so form and layouts don't accidentaly get user info
  end

  # Remaining actions are used only on venue/users routes

  def index
    @users = @venue.users.accessible_by current_ability
  end

  def new
    @user = @venue.users.build
    authorize! :create, @user
  end

  def create
    @user = User.new params_for_user
    role = params[:user][:roles]
    @user.roles = role if User.valid_venue_roles.map(&:to_s).include?(role)
    @user.venue_id = current_user.venue_id
    @user.generate_unusable_password!

    authorize! :create, @user


    if @user.save
      @user.send_activation_email
      redirect_to venue_users_path, notice: 'User created'
    else
      render :new
    end
  end

  def edit
    @user = @venue.users.find(params[:id])

    authorize! :update, @user
  end

  def update
    @user = @venue.users.find(params[:id])
    authorize! :update, @user

    if @user.update_attributes update_params_for_user
      redirect_to venue_users_path, notice: 'User updated'
    else
      render :edit
    end
  end

  def destroy
    @user = @venue.users.find(params[:id])

    authorize! :delete, @user
    @user.destroy

    redirect_to venue_users_path, notice: 'User deleted'
  end

  private

  def find_venue
    @venue = current_user.venue
  end

  def find_user_by_token
    @user = User.find_by_reset_token!(params[:reset_token])
    render action: :token_expired if @user.reset_token_date < 1.day.ago
  end

  def params_for_venue_owner
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def params_for_user
    params.require(:user).permit(:name, :email, :partner_id)
  end

  def update_params_for_user
    params.require(:user).permit(:name, :email, :roles, :partner_id)
  end

  def params_for_reset
    params.require(:user).permit(:password, :password_confirmation)
  end
end
