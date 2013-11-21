class PagesController < ApplicationController
  skip_authorization_check

  def index
    redirect_to admin_root_path and return if current_user && current_user.has_role?(:site_admin)
    redirect_to new_batch_partner_temporary_cards_path and return if current_user && current_user.has_role?(:venue_partner)
    redirect_to venue_path and return if current_user
    redirect_to login_path and return if mobile_device?
  end
end
