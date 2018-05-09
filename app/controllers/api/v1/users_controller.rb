class Api::V1::UsersController < Api::ApplicationController
  before_action :authenticate_from_access_token

  # POST /api/v1/users
  def create
    # TechOps is using this endpoint to create new users,
    # as well as update existing users.
    # It's a little unconventional, but that's what's happening.
    @user = User.where(email: email).first_or_initialize

    if @user.update(secure_params)
      render json: { success: true, user: @user.to_json }, status: :created
    else
      render json: { success: false, errors: @user.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/users
  def destroy_by_email
    @user = User.where(email: email).first

    if @user and @user.destroy
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: ['User not found'] }, status: :not_found
    end
  end

  private

  def secure_params
    attrs = params.permit(
      :name, :email, :role, :title, :avatar, :team_id, :staff,
      { fabs_attributes: [:id, :gif_tag_file_name] }
    ).tap do |whitelisted|
      # allow TechOps to send emails as strings or arrays
      whitelisted[:personal_emails] = params[:personal_emails] if params[:personal_emails]
    end
    attrs
  end

  def email
    "#{params[:username]}@eff.org"
  end

  def personal_emails
    params.fetch(:personal_emails, '').split(',').flatten.compact.uniq
  end
end
