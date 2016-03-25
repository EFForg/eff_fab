require_relative '../mailers'

namespace :mail do

  desc "Send Reminder for people to fill out their fab"
  task send_reminder: :environment do
    turbo_remind
  end

  desc "Send a notice that shames members who failed to fill out their fab"
  task send_reminder: :environment do
    turbo_shame
  end

end
