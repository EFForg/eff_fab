module WhereHelper
  def where_or_stub_for(user)
    user.last_whereabouts || WhereMessage.new(body: I18n.t('shruggie'))
  end

  def mattermost_dm_link(user)
    "https://mattermost.eff.org/eff/messages/@#{user.username}"
  end
end
