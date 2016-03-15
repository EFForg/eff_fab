#!/bin/sh

# include parse_yaml function
. /home/vagrant/dev/eff_fab/lib/parse_yaml.sh

# read yaml file
eval $(parse_yaml /home/vagrant/dev/eff_fab/config/application.yml)

# access yaml content
echo $admin_password

curl --data "admin_password=$admin_password" http://localhost:3000/tools/send_reminders
