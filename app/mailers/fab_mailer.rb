class FabMailer < ApplicationMailer
  def remind(user)
    subject = '[FAB] Reminder'
    @user = user

    mail(to:@user.email, subject: subject) do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end

  def last_minute_remind(user)
    @user = user
    subject = "[FAB] Some members of your team are fab flunking!"
    subject = "[FAB] You still haven't done your FAB!" if @user.upcoming_fab_still_missing?

    mail(to:@user.email, subject: subject) do |format|
      format.html
    end
  end

  def report_on_aftermath(user)
    @user = user
    @failed_fab_users = Team.get_runners
    @fab_state = @user.get_fab_state
    subject = '[FAB] Cycle Concluded'

    case @fab_state
    when :i_missed_fab
      subject << ": A dastardly day, you missed fab =("
    when :a_team_mate_missed_fab
      subject << ": Too sadening, someone on your very team made us miss cake"
    when :someone_on_staff_missed_fab
      subject << ": Another achievement for you and your team, sadly... no cake..."
    when :happy_fab_cake_time
      subject << ": ACHIEVEMENT UNLOCKED, FAB PHEASANT SPOTTED WITH CAKE!!!!"
    end

    mail(to:@user.email, subject: subject) do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end

  def cake(user)
    subject = '[FAB] The FAB Pheasant Has Something Wonderful for You!'
    @user = user

    mail(to:@user.email, subject: subject) do |format|
      format.html
      # format.text { render text: 'some text!' }
    end
  end

end
