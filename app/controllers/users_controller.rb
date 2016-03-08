class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :admin_only, except: [:show, :index]

  def index
    @teams = Team.all.includes(users: :fabs)
  end

  def show
    @user = User.find(params[:id])
    unless current_user.admin?
      unless @user == current_user
        redirect_to :back, :alert => "Access denied."
      end
    end
  end

  # POST /users/:id
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def secure_params
    params.require(:user).permit(:role, :name,
      {fabs_attributes: [:id, :gif_tag_file_name]}
    )
  end

end
