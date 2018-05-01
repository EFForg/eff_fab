class PtoMailer < ApplicationMailer
  def remind(user)
    mail(to: user.email, subject: "Log PTO") do |format|
      format.html
      format.text
    end
  end
end
