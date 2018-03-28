module AuthHelpers
  def http_login(user)
    @env ||= {}
    @env['HTTP_AUTHORIZATION'] = user.api_key.access_token
  end
end
