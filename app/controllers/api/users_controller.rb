class Api::UsersController < Api::ApplicationController
  before_action :authenticate_user!
  before_action :admin_only

  def create
    @user = User.new(secure_params.merge(password: User.generate_password))

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      render json: "User deleted", status: :ok
    else
      render json: "User not found", status: :not_found
    end
  end

  private
  def secure_params
    params.require(:user).permit(:role, :avatar, :name, :email, :team_id,
      {fabs_attributes: [:id, :gif_tag_file_name]}
    )
  end
end
