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
    @fab = cycle_fab_by_period(:forward, params)

    @previous_fab_exists, @next_fab_exists = [true, true]
    render '/tools/ajax_forward_back.html.erb', layout: false
  end

  def previous_fab
    @fab = cycle_fab_by_period(:backward, params)

    @previous_fab_exists, @next_fab_exists = [true, true]
    render '/tools/ajax_forward_back.html.erb', layout: false
  end


  private

    # pass in a user_id and period in params and it will find the next or previous fab
    def cycle_fab_by_period(direction, params)
      user = User.find(params[:user_id])
      current_fab = find_or_create_base_fab(user, params)
      @fab = (direction == :forward) ? current_fab.exactly_next_fab : current_fab.exactly_previous_fab
    end

    # Sometimes a fab doesn't exist, so we might have to build one to use
    # as a base to find #prev or #next
    def find_or_create_base_fab(user, params)
      t = DateTime.parse(params[:fab_period])
      user.fabs.where(period: t..(t+7)).limit(1).first or
        user.fabs.build(period: t)
    end

end
