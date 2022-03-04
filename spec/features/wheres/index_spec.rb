require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.feature "The list of all users' most recent whereabouts", type: :feature do

  let!(:where1) do
    FactoryBot.create(:where_message, body: "Flex day at the Sunnydale job fair")
  end
  let!(:where2) do
    FactoryBot.create(:where_message,
                       subject: "Out sick", 
                       body: "Recovering from demon attack")
  end

  before do
   login_as(FactoryBot.create(:user))
   visit wheres_path
  end

  after { Warden.test_reset! }

  scenario "User sees the Whereabouts headline" do
    expect(page.find("#hero h1")).to have_content(
      "Where are your coworkers located on the time/space continuum?"
    )
    expect(page.find("#front img")["src"]).to match(/whereabouts-text-white/)
    expect(page.find("#front img")["alt"]).to eq("Whereabouts")
  end

  scenario "User can see everyone's most recent location" do
    expect(page).to have_content(where1.user.name)
    expect(page).to have_content(where1.body)
    expect(page).to have_content(where2.user.name)
    expect(page).to have_content(where2.body)
    expect(page).to have_content(where2.subject)
  end

  scenario "User can visit one user's historical whereabouts page" do
    expect(page).to have_link(
      where1.user.name, href: user_wheres_path(where1.user)
    )
  end
end
