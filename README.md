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

Setup the app as with most rails apps:
```
$  cp config/application.yml.example config/application.yml
$  bundle install
$  rake db:create
$  rake db:migrate
$  rake user:populate_users
```

Now you can boot up the server:
```
$  rails s
```

You'll want to notice the configuration file located at `config/application.yml`, an admin will have been generated with the supplied credentials, and also the secret_key_base will need to be recalculated via `rake secret` and insertered for the app to work.  


Setup
-----

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

Like the app, the API uses basic auth for authentication. Along with your request, you must pass basic auth credentials associated with a user who has the admin role. In other words if the basic auth name is [NAME], there must be user with admin credentials and the email address [NAME]@eff.org.

To create a user, POST to `/api/users` with
```
{
  "user" : {
    "role": "user",
    "name": "Neko",
    "title": "Office Dog"
    "team_id": [TEAM_ID],
    "email": "neko@eff.org"
  }
}
```
`TEAM_ID` is the numerical id of the team in the fab app. You can also omit this field and let the user fill in their team later.

To delete a user, DELETE to `/api/users` with
```
{
  "email": "[EMAIL]"
}
```

Credits
-------

License
-------
Forward and Back is licensed under the GPLv3. See LICENSE for more details.
