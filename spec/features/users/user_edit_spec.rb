include Warden::Test::Helpers
Warden.test_mode!

# Feature: User edit
#   As a user
#   I want to edit my user profile
#   So I can change my email address
feature 'User registration edit', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'user changes email address' do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit edit_user_registration_path(user)
    fill_in 'Email', :with => 'newemail@example.com'
    fill_in 'Current password', :with => user.password
    click_button 'Update'
    txts = [I18n.t( 'devise.registrations.updated'), I18n.t( 'devise.registrations.update_needs_confirmation')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  # Scenario: User cannot edit another user's profile
  #   Given I am signed in
  #   When I try to edit another user's profile
  #   Then I see my own 'edit profile' page
  scenario "user cannot cannot edit another user's registration", :me do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user, email: 'other@example.com')
    login_as(me, :scope => :user)
    visit edit_user_registration_path(other)
    expect(page).to have_content 'Edit User'
    expect(page).to have_field('Email', with: me.email)
  end

end

feature 'User profile edit' do
  scenario "user can edit own profile" do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit edit_user_path(user)
    fill_in 'Name', :with => 'Neko'
    fill_in 'Title', :with => 'Office Dog'
    click_button 'Update User'
    expect(page).to have_content 'User updated'
  end

  scenario "user can't edit another user's profile" do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user, email: 'other@example.com')
    login_as(me, :scope => :user)
    visit edit_user_path(other)
    expect(page).to have_content 'Access denied'
  end

  scenario "user can't delete own account" do
    me = FactoryGirl.create(:user)
    login_as(me, :scope => :user)
    visit edit_user_path(me)
    expect(page).to have_no_content 'Delete user'
  end
end
