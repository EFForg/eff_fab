class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :admin_only, except: [:show, :index]

  def index
    @teams = Team.all.includes(users: { current_period_fab: [:notes, :forward, :backward] }).to_a
  end

  def show
    @user = User.find(params[:id])
  end

  # POST /users/:id
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      respond_to do |format|
        format.html { redirect_to users_path, :notice => "User updated." }
        format.json { render json: @user }
       end
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

  def new
    @user = User.new
  end

  def overriden_create
    @user = User.new(secure_params.merge(password: User.generate_password))

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def secure_params
    params.require(:user).permit(:role, :avatar, :name, :email, :team_id,
      {fabs_attributes: [:id, :gif_tag_file_name]}
    )
  end

end
