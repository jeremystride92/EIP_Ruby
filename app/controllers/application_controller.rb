class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :resolve_layout
  helper_method :current_user

  # check_authorization :unless => :devise_controller?

  class AccessDenied < ::StandardError; end

  rescue_from AccessDenied do |exception|
    render file: 'public/404', formats: [:html], layout: false, status: 404 and return
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render file: 'public/404', formats: [:html], layout: false, status: 404 and return
  end

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def authenticate
    raise AccessDenied unless current_user
  end

  def resolve_layout
    if current_user && private_action?
      'venue'
    else
      'application'
    end
  end

  def self.public_actions(*actions)
    @public_actions = actions
  end

  def public_action?
    (self.class.instance_variable_get('@public_actions') || []).include? action_name.to_sym
  end

  def private_action?
    !public_action?
  end
  public_actions :index
end
