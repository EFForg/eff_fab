include Warden::Test::Helpers
Warden.test_mode!

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
feature 'User index page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User listed on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see my own email address
  scenario 'user sees own email address' do
    user = FactoryGirl.create(:user_admin)
    login_as(user, scope: :user)
    visit users_path
    expect(page).to have_content user.name
  end

  describe "tight timing logic of what I see when navigating to /users" do

    before :each do
      @user = FactoryGirl.create(:user)
      login_as(@user, scope: :user)
    end

    # written as per bug from wild...
    scenario "I navigate to /users on Monday, April 11th after due time, I should see Fabs for April 4th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-11 22:00").to_datetime
      stub_time!(t)

      visit users_path
      expect_the_week_beginning_april_4
    end

    scenario "I navigate to /users on Monday, April 11th before due time, I should see Fabs for April 4th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-11 1:00").to_datetime
      stub_time!(t)

      visit users_path
      expect_the_week_beginning_april_4
    end

    scenario "I navigate to /users on Tuesday, April 12th, I should see Fabs for April 4th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-12 22:00").to_datetime
      stub_time!(t)

      visit users_path
      expect_the_week_beginning_april_4
    end

    scenario "I navigate to /users on Wed, April 13th, I should see Fabs for April 4th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-13 22:00").to_datetime
      stub_time!(t)

      visit users_path
      expect_the_week_beginning_april_4
    end

    scenario "I navigate to /users on Friday, April 8th early, I should see Fabs for April 4th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-8 1:00").to_datetime
      stub_time!(t)

      visit users_path
      expect_the_week_beginning_april_4
    end

    scenario "I navigate to /users on Thursday, April 7th (before the prior Mondays fab is ripe), I should see Fabs for March 28th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-7 1:00").to_datetime
      stub_time!(t)

      visit users_path
      expect(page).to have_content "Week of March 28th, 2016"
      expect(page).to have_content "Week of April 4th, 2016"
    end

    scenario "I navigate to /users on Friday, April 15th (after the prior Mondays fab is ripe), I should see Fabs for April 11th" do
      t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2016-04-15 1:00").to_datetime
      stub_time!(t)

      visit users_path
      expect(page).to have_content "Week of April 11th, 2016"
      expect(page).to have_content "Week of April 18th, 2016"
    end

  end

end

def expect_the_week_beginning_april_4
  expect(page).to have_content "Week of April 4th, 2016"
  expect(page).to have_content "Week of April 11th, 2016"
end
