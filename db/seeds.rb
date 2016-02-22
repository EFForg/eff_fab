# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << u.email

u.name = "Hugh D’Andrade"
u.save

this_monday = DateTime.now - DateTime.now.wday + 1.day
last_monday = this_monday - 7.days

f = u.fabs.create(period: last_monday)
3.times { f.notes.create(body: "I did a thing", forward: false) }
3.times { f.notes.create(body: "I will do a thing", forward: true) }

f = u.fabs.create(period: this_monday)
3.times { f.notes.create(body: "I was SUPER", forward: false) }
3.times { f.notes.create(body: "I will be more super", forward: true) }
