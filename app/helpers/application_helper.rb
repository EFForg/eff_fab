module ApplicationHelper

  def adminy?
    current_user.try(:role) == "admin" || current_user.try(:admin_user_mode) == "admin_user_mode"
  end

end
