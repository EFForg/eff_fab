require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.feature "The list of all users' most recent whereabouts", type: :feature do

  let!(:where1) do
    FactoryGirl.create(:where, body: "Flex day at the Sunnydale job fair")
  end
  let!(:where2) do
    FactoryGirl.create(:where, body: "Sick recovering from demon attack")
  end

  before do
   login_as(FactoryGirl.create(:user))
   visit wheres_path
  end

  after { Warden.test_reset! }

  scenario "User can see everyone's most recent location" do
    expect(page).to have_content(where1.user.name)
    expect(page).to have_content(where1.body)
    expect(page).to have_content(where2.user.name)
    expect(page).to have_content(where2.body)
  end
end
