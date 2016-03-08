require_relative '../scrape_from_kittens'

namespace :user do
  desc "TODO"
  task scrape_from_kittens: :environment do
    scrape_procedure
  end

end
