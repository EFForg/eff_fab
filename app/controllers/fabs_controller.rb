class FabsController < ApplicationController
  before_action :set_fab, only: [:show, :edit, :update, :destroy]

  # GET /fabs
  # GET /fabs.json
  def index
    @fabs = Fab.all
  end

  # GET /fabs/1
  # GET /fabs/1.json
  def show
  end

  # GET /fabs/new
  def new
    @fab = Fab.new
  end

  # GET /fabs/1/edit
  def edit
  end

  # POST /fabs
  # POST /fabs.json
  def create
    @fab = Fab.new(fab_params)

    respond_to do |format|
      if @fab.save
        format.html { redirect_to @fab, notice: 'Fab was successfully created.' }
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
        format.html { redirect_to @fab, notice: 'Fab was successfully updated.' }
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
      format.html { redirect_to fabs_url, notice: 'Fab was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fab
      @fab = Fab.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fab_params
      params.require(:fab).permit(:user_id, :gif_tag,
        notes_attributes: [:id, :body, :_destroy]
      )
    end
end
