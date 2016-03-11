module ApplicationHelper

  def adminy?
    current_user.try(:role) == "admin" || current_user.try(:admin_user_mode) == "admin_user_mode"
  end

  def string_to_class_name(s)
    s.strip.tr(' ', '-').gsub(/[^0-9A-z.\-]/, '_')
  end

  # pass in the name for the button and team, and this generates the
  # button for filtering by that team
  def leet_filter_button(s)
    button_tag(s, onclick: "leetFilter.filterAllBut(this);")
  end

  def leet_filter_dropdown_option(s)
    content_tag(:option, s)
  end

  def page_identifier
    "#{controller.controller_name}-#{action_name}"
  end

end
