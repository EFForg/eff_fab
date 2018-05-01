Forward and Back
================

This is a rails app built to make it easy for organizations with many users keep track of what they themselves are doing and what things their coworkers are up to.  

Getting Started
---------------

Note:  These instructions assume you have experience deploying conventional rails apps.  

Install dependencies:

```
$  sudo apt-get install mysql-server libmysqlclient-dev imagemagic
```

If you want to run the unit tests you need to install PhantomJS directly from this link:
http://phantomjs.org/download.html


Setup
-----

###With Docker:
```
$ cp .env.example .env
$ cp docker-compose.yml.example docker-compose.yml
$ docker-compose up --build -d
$ docker-compose exec app rake db:setup
```

###Without Docker:
```
$  cp .env.example .env
$  bundle install
$  rake db:create
$  rake db:migrate
$  rake user:populate_users
$  rails s
```

### Populate Database Records
To prime up the database with a basic admin user, run `rake db:seed`.  To populate the app for EFF usage, login as the admin user (see application.yml for credentials) and navigate to `/admin` and click the button for `Populate Users`, this will scrape https://www.eff.org/about/staff for user names, emails, and pictures and plug them into the database.

### Setup Reminder Mailings
Reminders and report_on_aftermath notifications are sent over email via `rake mail:send_reminder` and `rake mail:send_report_on_aftermath` respectively.  It's clever to have these commands executed via cron.  An example crontab follows:

```
0 13 * * 5 bash -l -c "cd /path/to/eff_fab/ && /path/to/rake -t RAILS_ENV=production mail:send_reminder"
0 12 * * 1 bash -l -c "cd /path/to/eff_fab/ && /path/to/rake -t RAILS_ENV=production mail:send_reminder"
0 15 * * 1 bash -l -c "cd /path/to/eff_fab/ && /path/to/rake -t RAILS_ENV=production mail:send_reminder"
15 15 * * 1 bash -l -c "cd /path/to/eff_fab/ && /path/to/rake -t RAILS_ENV=production mail:send_last_minute_reminder"
```

### Customize the images

Drop in more images into `app/assets/images/banner_pool` to have them show up in that beautiful top banner.  If one image doesn't seem to work, it probably has a `+` sign or possibly something even more adventurous like a question mark, so try taking that out.  

Administering Users
-------------------

### From within the app

1. Log in as a user with the admin role.
2. Click "Administer" in the nav bar and click "Add new user".

### From the API

The API authenticates admin users through API tokens.  Admin users can view and create API tokens through their FAB profile.

Navigate to `/api/docs` for more information.

Credits
-------

License
-------
Forward and Back is licensed under the GPLv3. See LICENSE for more details.
