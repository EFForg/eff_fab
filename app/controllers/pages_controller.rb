class PagesController < ApplicationController
  before_action :admin_only, except: [:show, :index]

  def admin
    @user = current_user
  end

end
