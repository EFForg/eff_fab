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

  # FIXME: dry refactor with previous_fab
  def next_fab
    user = User.find(params[:user_id])
    current_fab = Fab.find(params[:fab_id])
    @fab = current_fab.next_fab

    render text: "no such fab" and return if @fab.nil?

    @previous_fab_exists, @next_fab_exists = @fab.which_neighbor_fabs_exist?

    render '/tools/ajax_forward_back.html.erb', layout: false
  end

  def previous_fab
    user = User.find(params[:user_id])
    current_fab = Fab.find(params[:fab_id])
    @fab = current_fab.previous_fab

    render text: "no such fab" and return if @fab.nil?

    @previous_fab_exists, @next_fab_exists = @fab.which_neighbor_fabs_exist?

    render '/tools/ajax_forward_back.html.erb', layout: false
  end

end
