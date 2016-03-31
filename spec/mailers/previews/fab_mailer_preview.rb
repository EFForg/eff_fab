# Preview all emails at http://localhost:3000/rails/mailers/fab_mailer
class FabMailerPreview < ActionMailer::Preview
  def remind
    FabMailer.remind(User.first)
  end

  def last_minute_remind
    FabMailer.last_minute_remind(User.first)
  end

  def shame
    FabMailer.shame(User.first)
  end

end
