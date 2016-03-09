class PagesController < ApplicationController
  before_action :admin_only

  def admin
    @user = current_user
  end

end
