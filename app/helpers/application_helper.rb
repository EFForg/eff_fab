module ApplicationHelper

  def adminy?
    current_user.try(:role) == "admin" || current_user.try(:admin_user_mode) == "admin_user_mode"
  end

  def string_to_class_name(s)
    s.strip.tr(' ', '-').gsub(/[^0-9A-z.\-]/, '-')
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
