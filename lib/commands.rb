class Commands
  USERNAME = { wherebot: 'Wherebot' }
  RESPONSE_TYPE =  { private: "ephemeral" }

  def initialize(args)
    @body = args[:text]
    @username = args[:user_name].remove("@")
    @token = args[:token]
    @command = args[:command]
  end

  def response
    if authentic?
      {
        response_type: response_type, username: USERNAME[:wherebot]
      }.merge(response_body)
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

  def response_body
    raise NoMethodError, "Subclass must declare its response body"
  end

  private

  def authentic?
    return false unless @token

    ActiveSupport::SecurityUtils.secure_compare(
      @token, ENV["MATTERMOST_TOKEN_#{command.upcase}"]
    )
  end
end
