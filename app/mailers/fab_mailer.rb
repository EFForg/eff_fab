class FabMailer < ApplicationMailer
  def remind(user)
    @user = user

    mail(to:@user.email, subject: 'FAB Reminder') do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end

  def denounce_fab_rogues(user)
    @user = user
    @failed_fab_users = Teams.runner_ups

    mail(to:@user.email, subject: 'FAB Reminder') do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end

end
