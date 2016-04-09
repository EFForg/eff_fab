module ApplicationHelper

  def adminy?
    current_user.try(:role) == "admin" || current_user.try(:admin_user_mode) == "admin_user_mode"
  end


  def string_to_class_name(s)
    s.strip.tr(' ', '-').gsub(/[^0-9A-z.\-]/, '-')
  end

  # TODO: this is now dead code
  # pass in the name for the button and team, and this generates the
  # button for filtering by that team
  def leet_filter_button(s)
    button_tag(s, onclick: "alert('this abandoned code needs to be refactored to pull out the name of the filter frmo this and pass it to the new function I made...');leetFilter.filterAllBut(this);")
  end

  def leet_filter_dropdown_option(s)
    content_tag(:option, s)
  end

  def page_identifier
    "#{controller.controller_name}-#{action_name}"
  end

  def pick_a_banner_image
    array = Dir.entries("app/assets/images/banner_pool").reject {|f| File.directory? f}

    w = DateTime.now.in_time_zone.cweek
    array.shuffle!(random: Random.new(w))

    d = DateTime.now.in_time_zone.yday
    i = d % array.length

    choice = array[i]
    "banner_pool/#{choice}"
  end

  def banner_image_path
    asset_path(pick_a_banner_image)
  end

end
