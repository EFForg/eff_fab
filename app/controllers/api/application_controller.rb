class Api::ApplicationController < ApplicationController
  protect_from_forgery with: :null_session

  private

  def authenticate_from_access_token
    api_key = ApiKey.find_by_access_token(request.headers["Authorization"])
    head :unauthorized unless api_key.owner.admin?
  end
end
