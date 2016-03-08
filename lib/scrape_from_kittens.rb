def scrape_procedure
  # Clear out existing users.
  User.delete_all

  # Create admin user
  u = CreateAdminService.new.call
  u.name = "Admin"
  u.save
  puts 'CREATED ADMIN USER: ' << u.email

  team_id = (Team.find_by name: 'Other')
  profiles = get_staff_profiles

  profiles.each do |profile|
    u = create_user_from_profile(profile, team_id)
  end
end

def get_staff_profiles()
  page = Nokogiri::HTML(open("https://www.eff.org/about/staff/"))
  profiles = page.css('.view-staff-staff-profiles-page-view .views-row')
end

def create_user_from_profile(profile, team)
  attrs = {}
  attrs[:name] = profile.css('h2').text
  attrs[:title] = profile.css('h3').text
  attrs[:email] = profile.css('.email').text
  attrs[:team] = team
  attrs[:password] = 'temporary'
  if not attrs[:email].blank?
    u = User.create(attrs)
    puts attrs[:name]
    if u.errors.messages.count > 0
      puts u.errors.messages
    end
  end
end