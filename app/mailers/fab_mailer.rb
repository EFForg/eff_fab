class FabMailer < ApplicationMailer
  def remind(user)
    subject = 'FAB Reminder'
    @user = user

    mail(to:@user.email, subject: subject) do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end


  def last_minute_remind(user)
    @user = user
    subject = "[E-S] Some members of your team are fab failing!"
    subject = "[E-S] You still haven't done your FAB!" if @user.upcoming_fab_still_missing?

    mail(to:@user.email, subject: subject) do |format|
      format.html
    end
  end


  def shame(user)
    @user = user
    @failed_fab_users = Team.runner_ups.users

    mail(to:@user.email, subject: 'FAB Reminder') do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end

end
