def scrape_procedure
  # Clear out existing users
  User.delete_all
  Team.delete_all
  Fab.delete_all

  # Create admin user
  u = CreateAdminService.new.call
  u.name = "Admin"
  u.save
  puts 'CREATED ADMIN USER: ' << u.email

  get_staff_profiles.each do |profile|
    u = create_user_from_profile(profile)
    build_fabs(u)
  end
end

def get_staff_profiles
  page = Nokogiri::HTML(open("https://www.eff.org/about/staff/"))
  page.css('.view-staff-staff-profiles-page-view .views-row')
end

def create_user_from_profile(profile)
  attrs = {}
  attrs[:name] = profile.css('.views-field-title').text.strip
  attrs[:title] = profile.css('.views-field-field-profile-title').text.strip
  attrs[:email] = profile.css('.views-field-field-profile-email').text.strip
  attrs[:team] = get_team(get_name_from(attrs[:title]))
  attrs[:password] = User.generate_password

  # Save each user and their photo.
  if not attrs[:email].blank?
    u = User.create(attrs)
    save_user_photo(u, profile)

    # Provide some status updates.
    puts attrs[:name]
    puts u.errors.messages if u.errors.messages.count > 0

    u
  end
end

def get_team(name)
  Team.find_by(name: name) ||
    Team.create(name: name, weight: get_weight(name))
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
  {
    "Activism" => 10,
    "International" => 15,
    "Engineering/Design" => 20,
    "Tech Projects" => 22,
    "Tech Ops" => 25,
    "Press/Graphics" => 30,
    "Legal" => 40,
    "Development" => 50,
    "Finance/HR" => 55,
    "Operations" => 60,
    "Executive" => 65,
    "Runner Up" => 999
  }
end

def get_name_from(title)
  if title.split(' ').any? { |word| %w(activist grassroots activism researcher writer strategist).include?(word.downcase) }
    "Activism"
  elsif title.split(' ').any? { |word| %w(international global).include?(word.downcase) }
    "International"
  elsif title.split(' ').any? { |word| %w(technologist technology).include?(word.downcase) }
    "Tech Projects"
  elsif title.split(' ').any? { |word| %w(systems infrastructure).include?(word.downcase) }
    "Tech Ops"
  elsif title.split(' ').any? { |word| %w(web software designer).include?(word.downcase) }
    "Engineering/Design"
  elsif title.split(' ').any? { |word| %w(legal attorney liberties legislative).include?(word.downcase) }
    "Legal"
  elsif title.split(' ').any? { |word| %w(press graphics).include?(word.downcase) }
    # idk, there weren't any when i wrote this
    "Press"
  elsif title.split(' ').any? { |word| %w(membership events).include?(word.downcase) }
    "Development"
  elsif title.split(' ').any? { |word| %w(finance accountant human).include?(word.downcase) }
    "Finance/HR"
  elsif title.split(' ').any? { |word| %w(operations).include?(word.downcase) }
    "Operations"
  elsif title.split(' ').any? { |word| %w(executive).include?(word.downcase) }
    "Executive"
  else
    "Runner Up"
  end
end
