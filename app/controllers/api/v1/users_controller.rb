class Api::V1::UsersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :login_by_basic_auth
  respond_to :json

  # POST /api/v1/users/create
  # {
  #   username: luke,
  #   password: "something awesome and super entropic",
  #   personal_email: [lskywalker@ilm.com, luke@skywalkerranch.com],
  #   staff: true
  # }
  def create
    if current_user.try(&:admin?)
      @user = User.new(
        email: "#{params[:username]}@eff.org",
        password: params[:password],
        personal_emails: params[:personal_email],
        staff: (params[:staff] || true)
      )
      if @user.save
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
