require_relative '../populate_users'

namespace :user do
  desc "TODO"
  task populate_users: :environment do
    scrape_procedure
  end

end
