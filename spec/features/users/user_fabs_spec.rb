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

  scenario "User sees the FAB headline" do
    log_me_in FactoryGirl.create(:user)
    visit user_fabs_path(@me)

    expect(page.find("#hero h1")).to have_content(
      "What are your coworkers up to this week?"
    )
    expect(page.find("#front img")["src"]).to match(/forward-text-white/)
    expect(page.find("#front img")["alt"]).to eq("Forward & Back")
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario 'User can see own historical FABs, including default backwards' do
    log_me_in FactoryGirl.create(:user)

    current_fab = FactoryGirl.create(:fab_due_in_current_period, user_id: @me.id)
    prev_fab = FactoryGirl.create(
      :fab, user_id: @me.id, period: current_fab.period - 1.week
    )
    old_fab = FactoryGirl.create(
      :fab, user_id: @me.id, period: current_fab.period - 2.weeks
    )
    old_fab.backward.each {|note| note.update(body: Faker::ChuckNorris.fact) }
    old_fab.forward.last.update(body: "I'm looking to the future")

    visit user_fabs_path(@me)

    # Should have an input for the current fab, not a list item
    current_note = current_fab.notes.pluck(:body).find(&:present?)
    expect(page).to have_xpath("//input[@value='#{current_note}']")
    expect(page).not_to have_content current_note

    # Should have a list item for each previous FAB
    prev_fab_section = all('.fab').first
    expect(prev_fab_section.find('h3').text).to eq prev_fab.display_date_for_header
    expect(prev_fab_section).to have_content(prev_fab.backward.pluck(:body).find(&:present?))
    expect(prev_fab_section).to have_content(old_fab.forward.last.body)

    old_fab_section = all('.fab')[1]
    expect(old_fab_section.find('h3').text).to eq old_fab.display_date_for_header
    expect(old_fab_section).to have_content(old_fab.backward.pluck(:body).find(&:present?))
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

  scenario "this week's backwards defaults to last week's forwards, and can be overridden" do
    log_me_in FactoryGirl.create(:user)

    last_forward = "some text"
    next_text = "next week i will..."
    # create last week's FAB
    last_fab = FactoryGirl.create(:fab_due_in_prior_period, user_id: @me.id)
    last_fab.forward.last.update(body: last_forward)

    visit user_fabs_path(@me)

    fill_in 'fab_notes_attributes_3_body', with: next_text
    click_button 'SUBMIT FAB'

    @me.reload
    fab = @me.current_period_fab

    # DB records the default back and the new forward
    expect(fab).to be_present
    expect(fab.backward.pluck(:body).select(&:present?))
      .to match_array(last_fab.forward.pluck(:body).select(&:present?))
    expect(fab.forward.pluck(:body)).to include(next_text)

    # UX shows the default back and the new forward
    visit user_fabs_path(@me)
    expect(all('.fab-note-inputs.back input').map(&:value)).to include(last_forward)
    expect(all('.fab-note-inputs.forward input').map(&:value)).to include(next_text)

    # update this week's FAB
    fill_in 'fab_notes_attributes_0_body', with: "updated text"
    click_button 'SUBMIT FAB'
    visit user_fabs_path(@me)
    expect(all('.fab-note-inputs.back input').map(&:value)).to include("updated text")
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
    one_previous_back = 1   # there should be an H3 for the previous fabs's Back
    one_previous_forward = 1# there should be an H3 for the previous fabs's Forward
    one_back_header = 1     # there's an H3 that's part of the figure that says "back"
    one_forward_header = 1  # there's an H3 that's part of the figure that says "forward"
    expect(c).to eq one_previous_back + one_previous_forward + one_back_header + one_forward_header
  end

  scenario "fabs display the date of the starting day of the current fab" do
    bring_up_my_fab

    # historic fabs display
    expect(find_all('h3').last.text)
      .to include(@me.fabs.second.period.strftime("%b %-d "))

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
