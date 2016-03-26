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
    log_me_in

    visit user_fabs_path(@me)

    # Should have an input that contains 'I have a note'
    expect(page).to have_xpath("//input[@value='I have a note']")
    first_fab_header_text = find_all('h3').first.text

    # The current period's fab shouldn't have an h3 since it's in the
    # input boxes
    expect(first_fab_header_text).not_to eq @me.fabs.first.display_date_for_header
    expect(page).not_to have_content 'I have a note'
  end


  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  scenario "user can edit own current fab" do
    log_me_in
    
    Capybara.current_session.driver.header 'Referer', root_path
    visit user_fabs_path(@me)

    fill_in 'fab_notes_attributes_0_body', :with => 'I did blah in the past'
    fill_in 'fab_notes_attributes_3_body', :with => 'I plan to do blah'

    click_button 'SUBMIT FAB'
    expect(page).to have_content(/Fab was successfully created\./)
  end

  scenario "user cannot edit the fabs of others" do
    bring_up_anothers_fab_edit

    # expect the page to not have any inputs for editing fab
    expect(page).to_not have_xpath("//input[@value='I have a note']")

    # FIXME:
    # Tribby removed the date of the fab showing here

    # expect the page to have content of the user's last fab
    # first_fab_header_text = find_all('h3').first.text

    first_fab_note_text = find_all('div.back').first.find_all('ul li').first.text
    expect(first_fab_note_text).to eq @other.fabs.first.backward.first.body
  end

end


def log_me_in
  @me = FactoryGirl.create(:user)
  login_as(@me, :scope => :user)
end

def bring_up_anothers_fab_edit
  log_me_in

  @other = FactoryGirl.create(:user_with_yesterweeks_fab, email: 'other@example.com')

  Capybara.current_session.driver.header 'Referer', root_path
  visit user_fabs_path(@other)
end
