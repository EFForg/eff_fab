class ToolsController < ApplicationController

  # POST /tools/send_reminders
  def send_reminders
    FabMailer.reminder(User.first).deliver_later
  end
end
