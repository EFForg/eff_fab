require 'commands'

class Commands::WhereIs < Commands
  def command
    "WhereIs"
  end

  def response_body
    if target_user.nil?
      {
        text: %(I couldn't find "#{target_username}".  Try typing their Mattermost name.)
      }
    elsif target_user.last_whereabouts.present?
      time = target_user.last_whereabouts.sent_at
      msg = "At #{time.strftime('%-l:%M%P')} on #{time.strftime('%m/%d/%y')}, #{target_user.name} sent \"#{target_user.last_whereabouts.body}\""
      {
        attachments: [{
          fallback: msg,
          title: "#{time.strftime('%-l:%M%P')}, #{time.strftime('%m/%d/%y')}:",
          author_name: target_user.name,
          text: target_user.last_whereabouts.body,
          color: "#008800"
        }]
      }
    else
      { text: "#{target_user.name} hasn't set a where recently." }
    end
  end

  def target_user
    @user ||= User.find_by(email: "#{target_username}@eff.org")
  end

  private

  def target_username
    @body.split(' ').first.remove("@")
  end
end
