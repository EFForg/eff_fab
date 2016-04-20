# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
Fab.delete_all
Note.delete_all

def create_teams
  Team.delete_all

  Team.create(name: "Activism", weight: 100)
  Team.create(name: "Press/ Graphics", weight: 110)
  Team.create(name: "Executive", weight: 190)
  Team.create(name: "Executive Support", weight: 180)
  Team.create(name: "Operations", weight: 170)
  Team.create(name: "Development", weight: 150)
  Team.create(name: "Finance/ HR", weight: 160)
  Team.create(name: "Tech Ops", weight: 140)
  Team.create(name: "Webdev", weight: 130)
  Team.create(name: "Tech Projects", weight: 120)
  Team.create(name: "Civil Liberties", weight: 90)
  Team.create(name: "Intellectual Property", weight: 80)
  Team.create(name: "International", weight: 70)
  Team.create(name: "Other", weight: 200)
end

def rand_team_id
  Team.all[rand(Team.count)].id
end


def build_fabs(u)
  this_monday = DateTime.now.in_time_zone - DateTime.now.in_time_zone.wday + 1.day
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

create_teams

i = 0
20.times { build_fabs(User.create(name: "AutoGenned User", email: "user#{i++}@example.com", team_id: rand_team_id)) }

u = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << u.email

u.name = "Hugh D\`Andrade"
u.save

build_fabs(u)
