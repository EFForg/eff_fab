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

To prime up the database, you can't really rely on `rake db:seed`, instead, login as the admin user (see application.yml) and navigate to `/admin` and click the button for `Populate Users`, this will scrape eff.org/about/staff for user names, emails, and pictures and plug them into the database.  


Credits
-------

License
-------
