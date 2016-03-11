class ToolsController < ApplicationController
  before_action :admin_only, except: [:next_fab, :previous_fab]

  # POST /tools/send_reminders
  def send_reminders
    User.all.each do |user|
      FabMailer.reminder(user).deliver_later
    end
  end

  def populate_users
    require File.expand_path('../../../lib/populate_users', __FILE__)
    scrape_procedure
    render text: 'User population complete.'
  end

  def next_fab
    user = User.find(params[:user_id])
    @fab = user.next_or_previous_fab(params[:fab_id])
    render '/tools/ajax_forward_back.html.erb', layout: false
  end

  def previous_fab
    user = User.find(params[:user_id])
    @fab = user.next_or_previous_fab(params[:fab_id], previous=true)
    render '/tools/ajax_forward_back.html.erb', layout: false
  end

end
