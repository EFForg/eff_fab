class PagesController < ApplicationController
  before_action :admin_only, except: [:home, :about]

  def admin
    @user = current_user
  end

end
