# use this script from controllers or rake tasks :)

def turbo_remind
  User.all.each do |user|
    FabMailer.remind(user).deliver_now if user.upcoming_fab_still_missing?
  end
end

def turbo_last_minute_remind
  User.all.each do |user|
    if user.upcoming_fab_still_missing? or user.upcoming_fab_still_missing_for_team_mate?
      FabMailer.last_minute_remind(user).deliver_now
    end
  end
end

def turbo_shame
  User.all.each do |user|
    FabMailer.shame(user).deliver_now if user.previous_fab_still_missing?
  end
end
