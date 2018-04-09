class Commands
  USERNAME = { wherebot: 'Wherebot' }
  RESPONSE_TYPE =  { private: "ephemeral" }

  def initialize(args)
    @username = args[:user_name]
    @token = args[:token]
    @command = args[:command]
  end

  def target_user
    @user ||= User.find_by(email: "#{@username}@eff.org")
  end

  def response
    if authentic?
      {
        response_type: response_type,
        username: USERNAME[:wherebot],
        text: message
      }
    else
      { failure: "Could not authenticate." }
    end
  end

  def response_type
    RESPONSE_TYPE[:private]
  end

  def command
    raise NoMethodError, "Subclass must declare its command"
  end

  private

  def authentic?
    return false unless @token

    ActiveSupport::SecurityUtils.secure_compare(
      @token, ENV["MATTERMOST_TOKEN_#{command.upcase}"]
    )
  end
end

class Commands::WhereIs < Commands
  def command
    "WhereIs"
  end

  def message
    if target_user.last_whereabouts.present?
      time = target_user.last_whereabouts.sent_at
      "At #{time.strftime('%-l:%M%P')} on #{time.strftime('%m/%d/%y')}, #{target_user.name} sent \"#{target_user.last_whereabouts.body}\""
    else
      "#{target_user.name} hasn't set a where recently."
    end
  end
end

class Commands::Where < Commands
  def initialize(args)
    @body = args[:text]
    super
  end

  def command
    "Where"
  end

  def message
    if create_where
      "Your whereabouts are now set to \"#{@body}\"."
    else
      "I couldn't save your message. Better send it it to where@eff.org :sweat_smile:"
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
