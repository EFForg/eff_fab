class Api::V1::MattermostController < Api::ApplicationController
  Dir["#{Rails.root}/lib/commands/*.rb"].each {|file| require_dependency file }

  skip_before_action :login_by_basic_auth

  def set_my_where
    render json: Commands::SetMyWhere.new(command_params).response
  end

  def where_is
    render json: Commands::WhereIs.new(command_params).response
  end

  def add_fab_forward
    render json: Commands::AddFabForward.new(command_params).response
  end

  def add_fab_back
    render json: Commands::AddFabBack.new(command_params).response
  end

  private

  def command_params
    params.permit(:user_name, :text, :token)
  end
end
