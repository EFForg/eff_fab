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
  scenario 'user sees own fab history' do
    log_me_in FactoryGirl.create(:user)

    @me.fabs << FactoryGirl.create(:fab_due_in_prior_period)
    @me.fabs << FactoryGirl.create(:fab_due_in_current_period)

    visit user_fabs_path(@me)

    # Should have an input that contains 'I have a note'
    expect(page).to have_xpath("//input[@value='I have a note']")

    first_fab_header_text = find_all('h4').first.text

    expect(first_fab_header_text).not_to eq @me.fabs.first.display_date_for_header
    expect(page).not_to have_content 'I have a note'
    expect(page).to have_content 'I have an old note'
  end


  scenario "user creates a new fab of marvelous expectations" do
    log_me_in

    visit user_fabs_path(@me)
    fill_in 'fab_notes_attributes_0_body', :with => "I'm making my fab"
    fill_in 'fab_notes_attributes_3_body', :with => "here's the forward I think..."
    click_button 'SUBMIT FAB'

    @me.reload
    fab = @me.fabs.first
    expect(@me.fabs.count).to eq 1
    expect(fab.period.yday).to eq  Fab.get_start_of_current_fab_period.yday
    expect(fab.backward.first.body).to eq  "I'm making my fab"
    expect(fab.forward.first.body).to eq  "here's the forward I think..."
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  scenario "user can edit own current fab" do
    bring_up_my_fab

    fill_in 'fab_notes_attributes_0_body', :with => 'I did blah in the past'
    fill_in 'fab_notes_attributes_3_body', :with => 'I plan to do blah'

    click_button 'SUBMIT FAB'
    expect(page).to have_content(/Fab was successfully updated\./)
  end

  scenario "user cannot edit the fabs of others" do
    bring_up_anothers_fab_edit

    # expect the page to not have any inputs for editing fab
    expect(page).to_not have_xpath("//input[@value='I have a note']")

    first_fab_note_text = find_all('div.back').first.find_all('ul li').first.text
    first_fab_note_text = strip_unprintable_characters(first_fab_note_text)

    expect(first_fab_note_text).to eq @other.fabs.first.backward.first.body.to_s

    # this test section ensures the count of historic fabs is accurate.
    # there was a controller bug where it wasn't shifting off the top of the list
    c = find_all('h3').count
    one_historic_header = 1 # there should be just 1 h3 containing the date of a historic fab
    one_back_header = 1     # there's an H3 that's part of the figure that says "back"
    one_forward_header = 1  # there's an H3 that's part of the figure that says "forward"
    expect(c).to eq one_historic_header + one_back_header + one_forward_header
  end

  scenario "fabs display the date of the starting day of the current fab" do
    bring_up_my_fab

    # historic fabs display
    first_fab_header_text = find_all('h3').last.text
    expect(first_fab_header_text).to eq @me.fabs.second.display_date_for_header

    # currently editable fabs display
    editable_fab_header_text = find_all('h4').first.text
    editable_fab_header_text_forward = find_all('h4').last.text

    expect(editable_fab_header_text.downcase).to eq @me.fabs.first.display_back_start_day.downcase
    expect(editable_fab_header_text_forward.downcase).to eq @me.fabs.first.display_forward_start_day.downcase
  end

end


def log_me_in(me = nil)
  @me = me.nil? ? FactoryGirl.create(:user) : me

  login_as(@me, :scope => :user)
end

def bring_up_my_fab
  log_me_in FactoryGirl.create(:user_with_yesterweeks_fab)
  # Capybara.current_session.driver.header 'Referer', root_path
  visit user_fabs_path(@me)
end

def bring_up_anothers_fab_edit
  log_me_in

  @other = FactoryGirl.create(:user, email: 'other@example.com')
  @other.fabs << FactoryGirl.create(:fab_due_in_prior_period)

  @other.fabs << FactoryGirl.create(:fab_due_in_current_period)

  # Capybara.current_session.driver.header 'Referer', root_path
  visit user_fabs_path(@other)
end

# The markup contains a &zwnj; which is confusing and annoying as hell
def strip_unprintable_characters(s)
  s.tr(8204.chr, "")
end
