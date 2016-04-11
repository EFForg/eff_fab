Eff Fab
================

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](https://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.

Ruby on Rails
-------------

This application requires:

- Ruby 2.2.1

Learn more about [Installing Rails](https://railsapps.github.io/installing-rails.html).

Getting Started
---------------

Install dependencies, or use [mah vagrant box](https://github.com/TheNotary/ruby_vagrant_box).

```
$  sudo apt-get install mysql-server libmysqlclient-dev imagemagic
```

If you want to run the unit tests you need to install PhantomJS directly from this link:
http://phantomjs.org/download.html

Setup the app as with most rails apps
```
$  cp config/application.yml.example config/application.yml
$  bundle install
$  rake db:create
$  rake db:migrate
$  rake db:seed
```

Now you can boot up the server
```
$  rails s
```

You may want to notice the configuration file located at `config/application.yml`

Setup
-----

##### Populate Database Records
To prime up the database with a basic admin user, run `rake db:seed`.  To populate the app for EFF usage, login as the admin user (see application.yml for credentials) and navigate to `/admin` and click the button for `Populate Users`, this will scrape https://www.eff.org/about/staff for user names, emails, and pictures and plug them into the database.  It takes a while...

##### Setup Reminder Mailings
Reminders and report_on_aftermath notifications are sent over email via `rake mail:send_reminder` and `rake mail:send_report_on_aftermath` respectively.  It's clever to have these commands executed via cron.  An example crontab follows:

```
0 12 * * 5 bash -l -c "cd /www/fab.int.eff.org/ && rake mail:send_reminder

0 12 * * 1 bash -l -c "cd /www/fab.int.eff.org/ && rake mail:send_reminder
0 15 * * 1 bash -l -c "cd /www/fab.int.eff.org/ && rake mail:send_reminder
15 15 * * 1 bash -l -c "cd /www/fab.int.eff.org/ && rake mail:send_last_minute_reminder

0 16 * * 1 bash -l -c "cd /www/fab.int.eff.org/ && rake mail:send_report_on_aftermath
```

##### Customize the images

Drop in more images into `app/assets/images/banner_pool` to have them show up in that beautiful top banner.  If one image doesn't seem to work, it probably has a `+` sign or possibly something even more adventurous like a question mark, so try taking that out.  


Credits
-------

License
-------
