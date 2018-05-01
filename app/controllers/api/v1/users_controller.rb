class Api::V1::UsersController < Api::ApplicationController
  before_action :authenticate_from_access_token

  # POST /api/v1/users
  def create
    @user = User.where(email: email).first_or_initialize
    @user.update(secure_params.merge(
      password: User.generate_password,
      personal_emails: personal_emails
    ))

    if @user.save
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
    params.permit(
      :name, :email, :role, :title, :avatar, :team_id, :staff,
      { fabs_attributes: [:id, :gif_tag_file_name] }
    )
  end

  def email
    "#{params[:username]}@eff.org"
  end

  def personal_emails
    params.fetch(:personal_emails, '').split(',').flatten.compact.uniq
  end
end
