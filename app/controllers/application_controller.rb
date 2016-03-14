class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :login_by_basic_auth

  def admin_only
    unless current_user.try(:admin?) || current_user.try(:admin_user_mode?)
      redirect_to '/', :alert => "Access denied."
    end
  end

  def login_by_basic_auth
    if ActionController::HttpAuthentication::Basic::has_basic_credentials?(request)
      name = ActionController::HttpAuthentication::Basic::user_name_and_password(request)[0]
      user = User.where(email: name + "@eff.org")[0]
      sign_in :user, user if user
    end
  end

end
