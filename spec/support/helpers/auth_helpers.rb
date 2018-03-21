module AuthHelpers
  def http_login(user)
    @env ||= {}
    name = user.email.gsub('@eff.org', '')
    pw = 'password'
    @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(name,pw)
  end  
end
