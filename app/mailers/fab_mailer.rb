class FabMailer < ApplicationMailer
  def reminder(user)
    @user = user
    @url = 'https//example.com'
    mail(to:@user.email, subject: 'FAB Reminder')
  end
end
