class Api::V1::MattermostController < Api::ApplicationController
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
    head :unauthorized unless params[:token] &&
      params[:team_domain] &&
      ActiveSupport::SecurityUtils.secure_compare(
        params[:token], ENV['MATTERMOST_TOKEN']
      ) &&
      ActiveSupport::SecurityUtils.secure_compare(
        params[:team_domain], ENV['MATTERMOST_DOMAIN']
      )
  end

  def command_params
    params.permit(:user_name, :command, :text)
  end
end
