require 'commands'

class Commands::SetMyWhere < Commands
  def target_user
    @user ||= User.find_by(email: "#{@username}@eff.org")
  end

  def command
    "Where"
  end

  def response_body
    { text: message }
  end

  def message
    if target_user.present? && create_where
      %(Your whereabouts are now set to "#{@body}".)
    else
      "I couldn't save your message. Better send it to where@eff.org :sweat_smile:"
    end
  end

  private

  def create_where
    target_user.where_messages.create(
      provenance: WhereMessage::PROVENANCES[:mattermost],
      body: @body,
      sent_at: DateTime.now
    ).persisted?
  end
end
