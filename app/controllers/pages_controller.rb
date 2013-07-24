class PagesController < ApplicationController
  skip_authorization_check

  def index
    redirect_to admin_root_path and return if current_user && current_user.has_role?(:site_admin)
    redirect_to venue_path if current_user
  end
end
