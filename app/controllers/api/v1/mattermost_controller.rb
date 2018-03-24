class Api::V1::MattermostController < ApplicationController
  before_action :authenticate_mattermost

  def create
    if params[:command]
      render json: Commands.run(command_params).response
    else
      head :unauthorized
    end
  end

  private

  def authenticate_mattermost
    auth_present = params[:token] && params[:team_domain]
    valid_token = params[:token] == ENV['MATTERMOST_TOKEN']
    valid_team = params[:team_domain] == ENV['MATTERMOST_DOMAIN']

    head :unauthorized unless auth_present && valid_token && valid_team
  end

  def command_params
    params.permit(:user_name, :command, :text)
  end
end
