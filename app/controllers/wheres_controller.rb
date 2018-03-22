class WheresController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def user_list
    @user = User.find(params[:user_id])
    @wheres = @user.where_messages.order('sent_at DESC')
  end
end
