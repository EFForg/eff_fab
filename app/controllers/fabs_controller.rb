class FabsController < ApplicationController
  before_action :set_user
  before_action :set_fab, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:update, :create]
  before_action :author_access_only, only: [:update, :create]


  # GET /fabs
  # GET /fabs.json
  def index
    @fabs = @user.fabs.includes(:forward).includes(:backward).to_a

    # only show an edit form if it's the owner of the fab
    # if the user is allowed to edit this fab
    @fab_editable = current_user == @user ? true : false

    @fab = @user.fabs.find_or_build_this_periods_fab
    @fabs.shift unless @fab.new_record?

    @fab_period = Fab.get_start_of_current_fab_period
  end

  # GET /fabs/1
  # GET /fabs/1.json
  def show
  end

  # GET /fabs/new
  def new
    @fab = @user.fabs.find_or_build_this_periods_fab
  end

  # GET /fabs/1/edit
  def edit
  end

  # POST /fabs
  # POST /fabs.json
  def create
    redirect_to '/', :alert => "Access denied." if current_user != @user

    @fab = current_user.fabs.new(fab_params.merge(period: DateTime.now.in_time_zone))

    respond_to do |format|
      if @fab.save
        format.html { redirect_to [@user, @fab], notice: 'Fab was successfully created.' }
        format.json { render :show, status: :created, location: @fab }
      else
        format.html { render :new }
        format.json { render json: @fab.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fabs/1
  # PATCH/PUT /fabs/1.json
  def update
    respond_to do |format|
      if @fab.update(fab_params)
        format.html { redirect_to :user_fabs, notice: 'Fab was successfully updated.' }
        format.json { render :show, status: :ok, location: @fab }
      else
        format.html { render :edit }
        format.json { render json: @fab.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fabs/1
  # DELETE /fabs/1.json
  def destroy
    @fab.destroy
    respond_to do |format|
      format.html { redirect_to user_fabs_url, notice: 'Fab was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fab
      @fab = @user.fabs.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fab_params
      params.require(:fab).permit(:user_id, :gif_tag, :period,
        notes_attributes: [:id, :body, :_destroy, :forward]
      )
    end
end
