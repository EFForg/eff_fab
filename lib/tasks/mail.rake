require_relative '../mailers'
require_relative '../wherebot'

namespace :mail do

  desc "Send Reminder for people to fill out their fab"
  task send_reminder: :environment do
    turbo_remind
  end

  desc "Send a notice that report_on_aftermaths members who failed to fill out their fab"
  task send_report_on_aftermath: :environment do
    turbo_report_on_aftermath
  end

  desc "Send Reminder for people to fill out their fab"
  task send_last_minute_reminder: :environment do
    turbo_last_minute_remind
  end

  desc "Get where_messages from wherebot@eff.org"
  task :update_wheres, [:destructive] => :environment do |t, args|
    Wherebot.update_wheres(destructive: args[:whatever_arg_that_is])
  end
end
