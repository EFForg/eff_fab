module NavHelper
  def teams_key
    @teams.nil? ? nil : @teams.map(&:updated_at).join
  end

  def nav_cache_key
    [
      params[:controller] == "users",
      params[:action] == "index",
      current_user.try(:admin?),
      user_signed_in?,
      teams_key
    ]
  end

  def on_fabs_list
    (params[:controller] == "users") and (params[:action] == "index")
  end
end
