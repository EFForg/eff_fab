class Commands
  USERNAME = { wherebot: 'Wherebot' }
  RESPONSE_TYPE =  { private: "ephemeral" }

  def initialize(args)
    puts 'initialising'
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

  private

  def authentic?
    return false unless @command && @token

    ActiveSupport::SecurityUtils.secure_compare(
      @token, ENV["MATTERMOST_TOKEN_#{command.upcase}"]
    )
  end

  def command
    command = @command
    command = command.remove('/')
    command.camelcase
  end

  class << self
    def run(args)
      subclass(args[:command]).new(args)
    end

    private

    def subclass(name)
      name = name[1..-1] if !name[0].match(/[a-z]/i)
      "#{self.name}::#{name.titlecase}".constantize
    end
  end
end

class Commands::WhereIs < Commands
  def initialize(args)
    @username = args[:username]
    super
  end

  def message
    if target_user.last_whereabouts.present?
      "#{target_user.name}'s last known whereabouts are: #{target_user.last_whereabouts.body}"
    else
      "#{target_user.name} hasn't set a where recently."
    end
  end
end

class Commands::Where < Commands
  def initialize(args)
    @username = args[:user_name]
    @body = args[:text]
    super
  end

  def message
    if create_where
      "Your whereabouts are now set to #{@body}."
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
