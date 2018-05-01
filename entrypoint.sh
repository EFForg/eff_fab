#!/bin/sh

# Install any missing gems without rebuilding
bundle install --quiet

# Run migrations, if desired
if [ "$DB_MIGRATE" = "true" ]; then
  bundle exec rake db:migrate
fi

exec "$@"
