class Admin::BaseController < ApplicationController
  before_filter :authenticate
  before_filter :namespace_view_path

  private
  #
  # Allow namespaced template inheritance in application directory
  def namespace_view_path
    prepend_view_path 'app/views/admin'
  end
end
