class Api::V1::UsersController < Api::ApplicationController
  before_action :authenticate_from_access_token

  # POST /api/v1/users
  def create
    # In practice, TechOps is using this endpoint to create new users,
    # as well as update and look at existing users.
    # It's a little unconventional, but that's what's happening.
    @user = User.where(email: email).first_or_initialize

    if create_update_or_view
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

  def new_params
    new_params = secure_params
    new_params.merge(password: User.generate_password) if @user.new_record?
    new_params.merge(personal_emails: personal_emails) if personal_emails.any?
  end

  def create_update_or_view
    if new_params || @user.new_record?
      @user.save(new_params)
    else
      @user
    end
  end
end
