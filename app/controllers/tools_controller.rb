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
    user_id = params[:user_id]
    fab_id = params[:fab_id]
    # FIXME: this is a stub
    @fab = Fab.last
    render '/tools/ajax_forward_back.html.erb', layout: false
  end

  def previous_fab
    user_id = params[:user_id]
    fab_id = params[:fab_id]
    # FIXME: this is a stub
    @fab = Fab.last
    render '/tools/ajax_forward_back.html.erb', layout: false
  end

end
