class Api::UsersController < Api::ApplicationController
  before_action :authenticate_user!
  before_action :admin_only

  def create
    @user = User.new(secure_params.merge(password: User.generate_password))

    if @user.save
      render json: { success: true, user: @user }, status: :created
    else
      render json: { success: false, errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def destroy_by_email
    @user = User.where(email: params[:email]).first

    if @user and @user.destroy
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: ['User not found'] }, status: :not_found
    end
  end

  private
  def secure_params
    params.require(:user).permit(:role, :title, :avatar, :name, :email, :team_id,
      {fabs_attributes: [:id, :gif_tag_file_name]}
    )
  end
end
