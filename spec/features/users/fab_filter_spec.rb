# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'users fabFilter' do

  before :each do
    # populate teams
    FactoryBot.create(:team, name: "activism", weight: 1)
    FactoryBot.create(:team, name: "international", weight: 2)
    FactoryBot.create(:team, name: "web development", weight: 3)
    FactoryBot.create(:team, name: "tech projects", weight: 4)
    FactoryBot.create(:team, name: "tech ops", weight: 5)
    FactoryBot.create(:team, name: "press/graphics", weight: 6)
    FactoryBot.create(:team, name: "legal", weight: 7)
    FactoryBot.create(:team, name: "development", weight: 8)
    FactoryBot.create(:team, name: "finance/hr", weight: 13)
    FactoryBot.create(:team, name: "operations", weight: 14)
    FactoryBot.create(:team, name: "executive", weight: 15)
  end

  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'Big functional test', :js => true do
    visit '/users'

    # starts on cleared filter option
    expect_fab_filter_selected_to_display("All teams")

    # steps off filter forwards
    page.evaluate_script("fabFilter.cycleNextCategory(fabFilter);")

    expect_fab_filter_selected_to_display("activism")

    page.evaluate_script("fabFilter.cycleNextCategory(fabFilter);")
    expect_fab_filter_selected_to_display("international")

    page.evaluate_script("fabFilter.cycleNextCategory(fabFilter);")
    expect_fab_filter_selected_to_display("web development")

    3.times { page.evaluate_script("fabFilter.cycleNextCategory(fabFilter);") }
    expect_fab_filter_selected_to_display("press/graphics")

    # can go back
    3.times { page.evaluate_script("fabFilter.cyclePrevCategory(fabFilter);") }
    expect_fab_filter_selected_to_display("web development")

    # wraps around array in reverse direction
    4.times { page.evaluate_script("fabFilter.cyclePrevCategory(fabFilter);") }
    expect_fab_filter_selected_to_display("Team Runner Up")

    # wraps around array in forward direction and can land on cleared filter option
    1.times { page.evaluate_script("fabFilter.cycleNextCategory(fabFilter);") }
    expect_fab_filter_selected_to_display("All teams")
  end

  scenario 'Nitty Gritty stuff works on starting position...', js: true do
    visit '/users'

    expect_fab_filter_selected_to_display("All teams")

    # I don't know how to test this deep stuff
  end

end

def expect_fab_filter_selected_to_display(team_name)
  display_text = first_fab_header_text = find('#fabFilterSelectedDisplay').text
  expect(display_text).to eq team_name.upcase
  # expect(page).to have_select('nav-select', :selected => team_name)
end
