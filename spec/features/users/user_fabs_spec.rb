include Warden::Test::Helpers
Warden.test_mode!

# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
feature 'User fabs page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario 'user sees own fab history', js: true do
    user = FactoryGirl.create(:user_with_yesterweeks_fab)
    login_as(user, :scope => :user)
    visit user_fabs_path(user)

    # Should have an input that contains 'I have a note'
    expect(page).to have_xpath("//input[@value='I have a note']")
    first_fab_header_text = find_all('h3').first.text

    # The current period's fab shouldn't have an h3 since it's in the
    # input boxes
    expect(first_fab_header_text).not_to eq user.fabs.first.display_date_for_header
    expect(page).not_to have_content 'I have a note'
  end


  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  scenario "user can edit own current fab" do
    me = FactoryGirl.create(:user)
    login_as(me, :scope => :user)
    Capybara.current_session.driver.header 'Referer', root_path
    visit user_fabs_path(me)

    fill_in 'fab_notes_attributes_0_body', :with => 'I did blah in the past'
    fill_in 'fab_notes_attributes_3_body', :with => 'I plan to do blah'

    click_button 'SUBMIT FAB'
    expect(page).to have_content(/Fab was successfully created\./)
  end

  scenario "user cannot edit the fabs of others" do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user_with_yesterweeks_fab, email: 'other@example.com')
    login_as(me, :scope => :user)
    Capybara.current_session.driver.header 'Referer', root_path
    visit user_fabs_path(other)

    # expect the page to not have any inputs for editing fab
    expect(page).to_not have_xpath("//input[@value='I have a note']")

    # expect the page to have content of the user's last fab
    first_fab_header_text = find_all('h3').first.text
    expect(first_fab_header_text).to eq other.fabs.first.display_date_for_header
  end


end
