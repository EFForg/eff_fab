# Preview all emails at http://localhost:3000/rails/mailers/fab_mailer
class FabMailerPreview < ActionMailer::Preview
  def remind
    FabMailer.remind(User.first)
  end

  def last_minute_remind
    users = User.where(team: Team.find_by(name: "International"))
    recipient_user = users.second

    # run something like the below code to test the report_on_aftermath message when a team mate
    # is dropping the ball
    # users.first. fabs.delete_all

    FabMailer.last_minute_remind(recipient_user)
  end

  def report_on_aftermath
    FabMailer.report_on_aftermath(User.first)
  end

end
