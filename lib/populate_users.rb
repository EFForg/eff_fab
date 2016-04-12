def scrape_procedure
  debug_mode = true

  # Clear out existing users.
  User.delete_all
  Team.delete_all
  Fab.delete_all

  # Create admin user
  u = CreateAdminService.new.call
  u.name = "Admin"
  u.save
  puts 'CREATED ADMIN USER: ' << u.email

  team_id = Team.find_by(name: 'Other')
  profiles = get_staff_profiles

  profiles.each do |profile|
    u = create_user_from_profile(profile, team_id)
    build_fabs(u) if debug_mode
  end

  delete_other_team_if_not_needed
end

# The dogs create the other team, but don't count as real users... thus this func
def delete_other_team_if_not_needed
  t = Team.find_by(name: 'Other')
  t.delete if t && t.users.count == 0
end

def get_staff_profiles()
  page = Nokogiri::HTML(open("https://www.eff.org/about/staff/"))
  profiles = page.css('.view-staff-staff-profiles-page-view .views-row')
end

def create_user_from_profile(profile, team)
  attrs = {}
  attrs[:name] = profile.css('h2').text.strip
  attrs[:title] = profile.css('h3').text.strip
  attrs[:email] = profile.css('.email').text.strip
  attrs[:team] = get_team(profile)
  attrs[:password] = User.generate_password

  # Save each user and their photo.
  if not attrs[:email].blank?
    u = User.create(attrs)
    save_user_photo(u, profile)

    # Provide some status updates.
    puts attrs[:name]
    if u.errors.messages.count > 0
      puts u.errors.messages
    end
    return u
  end
end

def get_team(profile)
  name = profile.css('.views-field-field-profile-team').text.strip
  name = 'Other' if name.blank?

  if t = Team.find_by(name: name)
    return t
  else
    return Team.create(name: name, weight: get_weight(name))
  end
end

def save_user_photo(user, profile)
  path = profile.css('img').attr('src').to_s
  cleaned_path = path.sub('staff_thumb', 'medium').split('?').first
  user.avatar = URI.parse(cleaned_path)
  user.save
end

def build_fabs(u)
  return if u.nil?

  this_monday = Fab.get_start_of_current_fab_period
  last_monday = this_monday - 7.days

  f = u.fabs.create(period: last_monday)
  f.notes.delete_all
  3.times { f.notes.create(body: "I did a thing", forward: false) }
  3.times { f.notes.create(body: "I will do a thing", forward: true) }

  f = u.fabs.create(period: this_monday)
  f.notes.delete_all
  3.times { f.notes.create(body: "I was SUPER", forward: false) }
  3.times { f.notes.create(body: "I will be more super", forward: true) }
end

def get_weight(name)
  teams_and_weight[name]
end

def teams_and_weight
  # The team names were generated via the command...
  # Team.select(:name).map {|t| t.name }.to_json
  { "Activism" => 10,
    "International" => 15,

    "Web Development" => 20,
    "Tech Projects" => 22,
    "Tech Ops" => 25,

    "Press/Graphics" => 30,

    "Legal" => 40,

    "Development" => 50,
    "Finance/HR" => 55,

    "Operations" => 60,
    "Executive" => 65,
    "Other" => 999 }
end
