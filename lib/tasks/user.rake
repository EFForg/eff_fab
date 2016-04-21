require_relative '../populate_users'

namespace :user do
  desc "Populates the users of the app by scraping EFF.org/about/staff"
  task populate_users: :environment do
    scrape_procedure
  end

end
