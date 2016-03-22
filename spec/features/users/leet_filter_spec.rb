# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'users leetFilter' do

  before :each do
    # populate teams
    FactoryGirl.create(:team, name: "activism", weight: 1)
    FactoryGirl.create(:team, name: "international", weight: 2)
    FactoryGirl.create(:team, name: "web development", weight: 3)
    FactoryGirl.create(:team, name: "tech projects", weight: 4)
    FactoryGirl.create(:team, name: "tech ops", weight: 5)
    FactoryGirl.create(:team, name: "press/graphics", weight: 6)
    FactoryGirl.create(:team, name: "legal", weight: 7)
    FactoryGirl.create(:team, name: "development", weight: 8)
    FactoryGirl.create(:team, name: "finance/hr", weight: 13)
    FactoryGirl.create(:team, name: "operations", weight: 14)
    FactoryGirl.create(:team, name: "executive", weight: 15)
  end
  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'Big functional test', :js => true do
    visit '/users'

    # starts on cleared filter option
    expect(page).to have_select('nav-select', :selected => 'All teams')

    # steps off filter forwards
    page.evaluate_script("leetFilter.cycleNextCategory(leetFilter);")
    expect(page).to have_select('nav-select', :selected => 'activism')

    page.evaluate_script("leetFilter.cycleNextCategory(leetFilter);")
    expect(page).to have_select('nav-select', :selected => 'international')

    page.evaluate_script("leetFilter.cycleNextCategory(leetFilter);")
    expect(page).to have_select('nav-select', :selected => 'web development')

    3.times { page.evaluate_script("leetFilter.cycleNextCategory(leetFilter);") }
    expect(page).to have_select('nav-select', :selected => 'press/graphics')

    # can go back
    3.times { page.evaluate_script("leetFilter.cyclePrevCategory(leetFilter);") }
    expect(page).to have_select('nav-select', :selected => 'web development')

    # wraps around array in reverse direction
    4.times { page.evaluate_script("leetFilter.cyclePrevCategory(leetFilter);") }
    expect(page).to have_select('nav-select', :selected => 'Team Runner Up')

    # wraps around array in forward direction and can land on cleared filter option
    1.times { page.evaluate_script("leetFilter.cycleNextCategory(leetFilter);") }
    expect(page).to have_select('nav-select', :selected => 'All teams')
  end

  scenario 'Nitty Gritty stuff works on starting position...', js: true do
    visit '/users'

    expect(page).to have_select('nav-select', :selected => 'All teams')

    # I don't know how to test this deep stuff
  end

end
