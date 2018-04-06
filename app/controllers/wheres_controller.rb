class WheresController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all.order("name asc")
  end

  def user_list
    @user = User.find(params[:user_id])
    @wheres = @user.where_messages.order('sent_at DESC')
  end

  private

  def set_hero
    @hero_text = "Where are your coworkers located on the time/space continuum?"
    @hero_title = "Whereabouts"
    @hero_image = ActionController::Base.helpers.asset_path('whereabouts-text-white.png')
  end
end
